use quick_xml::de::from_str;
use rustler::{types::atom, Atom, Encoder, Env, Term};
use serde_json::Value;

/// Parses an XML string to an Elixir-compatible term.
///
/// # Returns
///   - `{:ok, map}` when the XML is successfully parsed and can be represented as a map.
///   - `{:error, {error_type, details}}` when the XML is not valid or cannot be parsed.
///
/// # Error types
///   - `:invalid_xml` if the XML is not valid.
///   - `:unexpected_eof` if the XML is not properly terminated.
///   - `:malformed_xml` if the XML is malformed.
///   - `:unknown_error` for other parsing errors.
#[rustler::nif]
fn parse(env: Env, xml: String) -> Term {
    // Attempt to parse the XML string into a serde_json Value
    let parsed: Result<Value, quick_xml::DeError> = from_str(&xml);
    handle_parsed_value(env, parsed)
}

fn handle_parsed_value(env: Env, parsed: Result<Value, quick_xml::DeError>) -> Term {
    match parsed {
        // If parsing succeeded and result is a JSON object, convert to Elixir map
        Ok(json_value) if json_value.is_object() => {
            let elixir_map = json_to_term(env, &json_value);
            (atom::ok(), elixir_map).encode(env)
        }
        // If parsing succeeded but result is not an object, return invalid_xml error
        Ok(_) => {
            let error_type = Atom::from_str(env, "invalid_xml").unwrap();
            let details = "syntax error: xml must have a node";
            (atom::error(), (error_type, details)).encode(env)
        }
        // If parsing failed, classify the error and return appropriate error tuple
        Err(err) => {
            let (error_type, details) = classify_xml_error(env, err);
            (atom::error(), (error_type, details)).encode(env)
        }
    }
}

// Converts a serde_json Value into an Elixir term that can be returned to the caller
fn json_to_term<'a>(env: Env<'a>, value: &Value) -> Term<'a> {
    match value {
        // Handle each JSON type and convert to appropriate Elixir term
        Value::Null => atom::nil().encode(env),
        Value::Bool(b) => b.encode(env),
        Value::Number(num) => {
            // Convert number based on its type
            if num.is_i64() {
                // Handle signed 64-bit integers (e.g. -123, 456)
                num.as_i64().encode(env)
            } else if num.is_u64() {
                // Handle unsigned 64-bit integers (e.g. 123456789)
                num.as_u64().encode(env)
            } else {
                // Handle floating point numbers (e.g. 123.456)
                num.as_f64().encode(env)
            }
        }
        Value::String(s) => s.encode(env),
        // Recursively convert arrays to Elixir lists
        Value::Array(arr) => {
            let terms: Vec<Term> = arr.iter().map(|v| json_to_term(env, v)).collect();
            terms.encode(env)
        }
        // Convert JSON objects to Elixir maps
        Value::Object(obj) => {
            let keys: Vec<Term> = obj.keys().map(|k| k.encode(env)).collect();
            let values: Vec<Term> = obj.values().map(|v| json_to_term(env, v)).collect();
            Term::map_from_arrays(env, &keys, &values).unwrap()
        }
    }
}

// Classifies XML parsing errors into specific error types with descriptive messages
fn classify_xml_error(env: Env, err: quick_xml::DeError) -> (Atom, Term) {
    use quick_xml::DeError::*;

    let (error_type, details) = match err {
        UnexpectedEof => ("unexpected_eof", None),
        InvalidXml(msg) => ("malformed_xml", Some(msg.to_string())),
        err => ("unknown_error", Some(format!("{:?}", err))),
    };

    let error_atom = Atom::from_str(env, error_type).unwrap();
    let detail_term = match details {
        Some(msg) => msg.encode(env),
        None => "no details".encode(env),
    };

    (error_atom, detail_term)
}

// Initialize the NIF module
rustler::init!("Elixir.QuickXml");
