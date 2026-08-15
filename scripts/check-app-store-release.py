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

require("PRODUCT_BUNDLE_IDENTIFIER: com.stormandme.afterstorm" in project, "App bundle identifier must be com.stormandme.afterstorm")
require("PRODUCT_BUNDLE_IDENTIFIER: com.stormandme.afterstorm.widget" in project, "Widget bundle identifier must be com.stormandme.afterstorm.widget")
require('MARKETING_VERSION: "1.0"' in project, "Marketing version must be 1.0")
require('CURRENT_PROJECT_VERSION: "1"' in project, "Build number must be 1")
require('INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO' in project, "Export-compliance declaration is missing")
require("group.com.stormandme.afterstorm" in entitlements, "App Group entitlement is missing")
require("iCloud.com.stormandme.afterstorm" in entitlements, "CloudKit entitlement is missing")

for rel in ["AfterStormApp/PrivacyInfo.xcprivacy", "AfterStormWidget/PrivacyInfo.xcprivacy"]:
    path = ROOT / rel
    require(path.exists(), f"Missing privacy manifest: {rel}")
    if path.exists():
        try:
            with path.open("rb") as handle:
                manifest = plistlib.load(handle)
            require(manifest.get("NSPrivacyTracking") is False, f"{rel} must explicitly disable tracking")
            require(manifest.get("NSPrivacyTrackingDomains") == [], f"{rel} must not declare tracking domains")
        except Exception as exc:
            errors.append(f"Invalid privacy manifest {rel}: {exc}")

for url in [
    "https://stormandmeofficial.com/afterstorm/privacy",
    "https://stormandmeofficial.com/afterstorm/support",
    "https://stormandmeofficial.com/afterstorm",
]:
    require(url in metadata, f"Store metadata is missing URL: {url}")

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
print("- iCloud/App Group entitlements: present")
print("- public store URLs: declared")
print("- credential leak guard: passed")
