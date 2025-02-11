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
    let parsed: Result<Value, quick_xml::DeError> = from_str(&xml);
    handle_parsed_value(env, parsed)
}

fn handle_parsed_value(env: Env, parsed: Result<Value, quick_xml::DeError>) -> Term {
    match parsed {
        Ok(json_value) if json_value.is_object() => {
            let elixir_map = json_to_term(env, &json_value);
            (atom::ok(), elixir_map).encode(env)
        }
        Ok(_) => {
            let error_type = Atom::from_str(env, "invalid_xml").unwrap();
            let details = "syntax error: xml must have a node";
            (atom::error(), (error_type, details.encode(env))).encode(env)
        }
        Err(err) => {
            let (error_type, details) = classify_xml_error(env, err);
            (atom::error(), (error_type, details.encode(env))).encode(env)
        }
    }
}

fn json_to_term<'a>(env: Env<'a>, value: &Value) -> Term<'a> {
    match value {
        Value::Null => atom::nil().encode(env),
        Value::Bool(b) => b.encode(env),
        Value::Number(num) => {
            if let Some(n) = num.as_i64() {
                n.encode(env)
            } else {
                num.as_f64().unwrap().encode(env)
            }
        }
        Value::String(s) => s.encode(env),
        Value::Array(arr) => {
            let terms: Vec<Term> = arr.iter().map(|v| json_to_term(env, v)).collect();
            terms.encode(env)
        }
        Value::Object(obj) => {
            let keys: Vec<Term> = obj.keys().map(|k| k.encode(env)).collect();
            let values: Vec<Term> = obj.values().map(|v| json_to_term(env, v)).collect();
            Term::map_from_arrays(env, &keys, &values).unwrap()
        }
    }
}

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
        None => atom::nil().encode(env),
    };

    (error_atom, detail_term)
}

rustler::init!("Elixir.QuickXml");
