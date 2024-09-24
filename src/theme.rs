use crate::models::practice::Colors;
use crate::data::practice_loader::get_practice_by_id;
use once_cell::sync::Lazy;
use std::sync::Mutex;
use serde::Deserialize;

#[derive(Clone, Debug, Deserialize)]
pub struct Theme {
    pub background_color: String,
    pub primary_color: String,
    pub secondary_color: String,
    pub tertiary_color: String,
    pub accent_color: String,
    pub text_primary: String,
    pub text_secondary: String,
    pub shadow_color: String,
}

impl Default for Theme {
    fn default() -> Self {
        Theme {
            background_color: "#0A0C11".to_string(),
            primary_color: "#004d4d".to_string(),
            secondary_color: "#006666".to_string(),
            tertiary_color: "#008080".to_string(),
            accent_color: "#00cccc".to_string(),
            text_primary: "#e6f3f3".to_string(),
            text_secondary: "#001a1a".to_string(),
            shadow_color: "rgba(0, 204, 204, 0.2)".to_string(),
        }
    }
}

pub static CURRENT_THEME: Lazy<Mutex<Theme>> = Lazy::new(|| Mutex::new(Theme::default()));

pub fn set_theme(practice_id: &str) {
    let mut theme = CURRENT_THEME.lock().unwrap();
    if let Some(practice) = get_practice_by_id(practice_id) {
        *theme = Theme {
            background_color: practice.visual.colors.background_color,
            primary_color: practice.visual.colors.primary_color,
            secondary_color: practice.visual.colors.secondary_color,
            tertiary_color: practice.visual.colors.tertiary_color,
            accent_color: practice.visual.colors.accent_color,
            text_primary: practice.visual.colors.text_primary,
            text_secondary: practice.visual.colors.text_secondary,
            shadow_color: practice.visual.colors.shadow_color,
        };
    } else {
        *theme = Theme::default();
    }
    
    // Apply the theme
    apply_theme(&theme);
}

pub fn get_current_theme() -> Theme {
    CURRENT_THEME.lock().unwrap().clone()
}

pub fn get_theme_css() -> String {
    let theme = get_current_theme();
    format!(
        ":root {{
            --background-color: {};
            --primary-color: {};
            --secondary-color: {};
            --tertiary-color: {};
            --accent-color: {};
            --text-primary: {};
            --text-secondary: {};
            --shadow-color: {};
        }}",
        theme.background_color,
        theme.primary_color,
        theme.secondary_color,
        theme.tertiary_color,
        theme.accent_color,
        theme.text_primary,
        theme.text_secondary,
        theme.shadow_color
    )
}

#[cfg(target_arch = "wasm32")]
fn apply_theme(theme: &Theme) {
    use wasm_bindgen::prelude::*;
    use wasm_bindgen::JsCast;
    use web_sys::{window, HtmlElement};

    if let Some(window) = window() {
        if let Some(document) = window.document() {
            if let Some(root) = document.document_element() {
                if let Some(html_element) = root.dyn_ref::<HtmlElement>() {
                    let style = html_element.style();
                    let _ = style.set_property("--background-color", &theme.background_color);
                    let _ = style.set_property("--primary-color", &theme.primary_color);
                    let _ = style.set_property("--secondary-color", &theme.secondary_color);
                    let _ = style.set_property("--tertiary-color", &theme.tertiary_color);
                    let _ = style.set_property("--accent-color", &theme.accent_color);
                    let _ = style.set_property("--text-primary", &theme.text_primary);
                    let _ = style.set_property("--text-secondary", &theme.text_secondary);
                    let _ = style.set_property("--shadow-color", &theme.shadow_color);
                }
            }
        }
    }
}

#[cfg(not(target_arch = "wasm32"))]
fn apply_theme(theme: &Theme) {
    println!("Applying theme (simulated for desktop):");
    println!("Background color: {}", theme.background_color);
    println!("Primary color: {}", theme.primary_color);
    println!("Secondary color: {}", theme.secondary_color);
    println!("Tertiary color: {}", theme.tertiary_color);
    println!("Accent color: {}", theme.accent_color);
    println!("Text primary: {}", theme.text_primary);
    println!("Text secondary: {}", theme.text_secondary);
    println!("Shadow color: {}", theme.shadow_color);
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_set_theme() {
        // This test assumes that get_practice_by_id is mocked or a test practice is available
        set_theme("whm_basic");
        let theme = get_current_theme();
        assert_eq!(theme.background_color, "#0A0C11");
        assert_eq!(theme.primary_color, "#004d4d");
    }

    #[test]
    fn test_default_theme() {
        let default_theme = Theme::default();
        assert_eq!(default_theme.background_color, "#0A0C11");
        assert_eq!(default_theme.primary_color, "#004d4d");
        assert_eq!(default_theme.secondary_color, "#006666");
    }
}