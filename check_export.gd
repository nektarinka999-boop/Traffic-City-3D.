
@tool
extends EditorScript

func _run() -> void:
    print("=== TRAFFIC CITY 3D EXPORT DIAGNOSTICS ===")

    var presets := EditorExport.get_export_presets()
    print("Number of export presets: ", presets.size())

    for preset in presets:
        print("Preset name: ", preset.get_name())
        print("Platform: ", preset.get_platform().get_name())

        var platform := preset.get_platform()
        var options := platform.get_export_options()

        for option in options:
            var name: String = option["name"]
            var warning := platform.get_export_option_warning(
                preset,
                name
            )

            if not warning.is_empty():
                print("WARNING FOR ", name, ": ", warning)

    print("=== DIAGNOSTICS FINISHED ===")
