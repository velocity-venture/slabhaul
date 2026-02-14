#!/usr/bin/env python3
"""Upload AAB to Google Play Internal Testing."""

import sys
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

# Configuration
SERVICE_ACCOUNT_FILE = 'slabhaul-deploy-05b8652c86e0.json'
PACKAGE_NAME = 'com.slabhaulapp.slabhaul'  # Your app's package name
AAB_FILE = 'build/app/outputs/bundle/release/app-release.aab'
TRACK = 'internal'  # internal, alpha, beta, or production

def upload_to_play_store():
    """Upload AAB to Google Play Store."""
    print(f"Authenticating with service account...")

    # Authenticate using service account
    credentials = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE,
        scopes=['https://www.googleapis.com/auth/androidpublisher']
    )

    # Build the service
    service = build('androidpublisher', 'v3', credentials=credentials)

    print(f"Creating edit for package: {PACKAGE_NAME}")

    # Create a new edit
    edit_request = service.edits().insert(
        packageName=PACKAGE_NAME,
        body={}
    )
    result = edit_request.execute()
    edit_id = result['id']

    print(f"Edit ID: {edit_id}")
    print(f"Uploading bundle: {AAB_FILE}")

    # Upload the AAB
    bundle_response = service.edits().bundles().upload(
        packageName=PACKAGE_NAME,
        editId=edit_id,
        media_body=MediaFileUpload(AAB_FILE, mimetype='application/octet-stream')
    ).execute()

    version_code = bundle_response['versionCode']
    print(f"Bundle uploaded successfully. Version code: {version_code}")

    # Assign bundle to track
    print(f"Assigning to {TRACK} track...")
    track_response = service.edits().tracks().update(
        packageName=PACKAGE_NAME,
        editId=edit_id,
        track=TRACK,
        body={
            'releases': [{
                'versionCodes': [version_code],
                'status': 'completed',  # completed means released to the track
            }]
        }
    ).execute()

    print(f"Bundle assigned to {TRACK} track")

    # Commit the edit
    print("Committing the edit...")
    commit_response = service.edits().commit(
        packageName=PACKAGE_NAME,
        editId=edit_id
    ).execute()

    print(f"✅ Successfully uploaded to Google Play {TRACK.upper()} track!")
    print(f"Edit ID: {commit_response['id']}")
    return True

if __name__ == '__main__':
    try:
        upload_to_play_store()
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
