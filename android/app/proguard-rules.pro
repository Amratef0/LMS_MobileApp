# Flutter's own gradle plugin already injects the rules the engine needs.
# Add project-specific keep rules here if you hit a ClassNotFoundException /
# NoSuchMethodError in a --release build that doesn't happen in --debug.

# file_picker uses a PlatformChannel, no reflection-based keep rules needed.
# dio/JSON parsing in this app is all hand-written (no json_serializable /
# reflection), so nothing extra to keep there either.
