
@tool
extends SceneTree

func _initialize() -> void:
    print("=== TRAFFIC CITY 3D DIAGNOSTICS ===")

    var settings := EditorInterface.get_editor_settings()

    var names := [
        "export/android/android_sdk_path",
        "export/android/java_sdk_path",
        "export/android/debug_keystore",
        "export/android/debug_keystore_user"
    ]

    for name in names:
        print("SETTING: ", name)
        print("EXISTS: ", settings.has_setting(name))

        if settings.has_setting(name):
            print("VALUE: ", settings.get_setting(name))

    print("=== DIAGNOSTICS FINISHED ===")
    quit()
