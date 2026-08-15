#!/usr/bin/env python3
from pathlib import Path
import plistlib
import sys

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []


def require(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


project = (ROOT / "project.yml").read_text(encoding="utf-8")
metadata = (ROOT / "docs/release/app-store-1.0.md").read_text(encoding="utf-8")
entitlements = (ROOT / "AfterStormApp/AfterStorm.entitlements").read_text(encoding="utf-8")
privacy_view = (ROOT / "AfterStormApp/Settings/PrivacyView.swift").read_text(encoding="utf-8")

require("PRODUCT_BUNDLE_IDENTIFIER: com.stormandme.afterstorm" in project, "App bundle identifier must be com.stormandme.afterstorm")
require("PRODUCT_BUNDLE_IDENTIFIER: com.stormandme.afterstorm.widget" in project, "Widget bundle identifier must be com.stormandme.afterstorm.widget")
require('MARKETING_VERSION: "1.0"' in project, "Marketing version must be 1.0")
require('CURRENT_PROJECT_VERSION: "1"' in project, "Build number must be 1")
require('INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO' in project, "Export-compliance declaration is missing")
require("group.com.stormandme.afterstorm" in entitlements, "App Group entitlement is missing")
require("iCloud.com.stormandme.afterstorm" in entitlements, "CloudKit entitlement is missing")

app_manifest_path = ROOT / "AfterStormApp/PrivacyInfo.xcprivacy"
widget_manifest_path = ROOT / "AfterStormWidget/PrivacyInfo.xcprivacy"

for path, rel in [
    (app_manifest_path, "AfterStormApp/PrivacyInfo.xcprivacy"),
    (widget_manifest_path, "AfterStormWidget/PrivacyInfo.xcprivacy"),
]:
    require(path.exists(), f"Missing privacy manifest: {rel}")
    if path.exists():
        try:
            with path.open("rb") as handle:
                manifest = plistlib.load(handle)
            require(manifest.get("NSPrivacyTracking") is False, f"{rel} must explicitly disable tracking")
            require(manifest.get("NSPrivacyTrackingDomains") == [], f"{rel} must not declare tracking domains")
        except Exception as exc:
            errors.append(f"Invalid privacy manifest {rel}: {exc}")

if app_manifest_path.exists():
    try:
        with app_manifest_path.open("rb") as handle:
            app_manifest = plistlib.load(handle)
        collected = app_manifest.get("NSPrivacyCollectedDataTypes", [])
        product_interaction = next(
            (item for item in collected if item.get("NSPrivacyCollectedDataType") == "NSPrivacyCollectedDataTypeProductInteraction"),
            None,
        )
        require(product_interaction is not None, "App privacy manifest must disclose CloudKit-synced Product Interaction")
        if product_interaction is not None:
            require(product_interaction.get("NSPrivacyCollectedDataTypeLinked") is True, "CloudKit-synced Product Interaction must be declared linked to the user")
            require(product_interaction.get("NSPrivacyCollectedDataTypeTracking") is False, "Product Interaction must not be used for tracking")
            require(
                "NSPrivacyCollectedDataTypePurposeAppFunctionality" in product_interaction.get("NSPrivacyCollectedDataTypePurposes", []),
                "Product Interaction must declare App Functionality purpose",
            )
    except Exception as exc:
        errors.append(f"Unable to validate app privacy collection details: {exc}")

privacy_url = "https://stormandmeofficial.com/afterstorm/privacy"
require(privacy_url in privacy_view, "Privacy & Data screen must link to the public AfterStorm privacy policy")

for url in [
    privacy_url,
    "https://stormandmeofficial.com/afterstorm/support",
    "https://stormandmeofficial.com/afterstorm",
]:
    require(url in metadata, f"Store metadata is missing URL: {url}")

require("Product Interaction" in metadata, "Store metadata must document the CloudKit Product Interaction privacy answer")
require("App Functionality" in metadata, "Store metadata must document the App Functionality purpose")
require("linked to the user" in metadata, "Store metadata must document that CloudKit Product Interaction is linked to the user")
require("not used for tracking" in metadata, "Store metadata must document that CloudKit Product Interaction is not used for tracking")

for forbidden in ["BEGIN PRIVATE KEY", "BEGIN CERTIFICATE", "ASC_PRIVATE_KEY", "APPLE_ID_PASSWORD"]:
    require(forbidden not in project and forbidden not in metadata, f"Release files must not contain credential material: {forbidden}")

if errors:
    print("App Store readiness check FAILED:")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)

print("App Store readiness check passed")
print("- bundle IDs: verified")
print("- version/build: 1.0 (1)")
print("- privacy manifests: valid")
print("- CloudKit Product Interaction disclosure: verified")
print("- in-app privacy policy link: verified")
print("- iCloud/App Group entitlements: present")
print("- public store URLs: declared")
print("- credential leak guard: passed")
