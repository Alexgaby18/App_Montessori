# App Montessori

App Montessori is a Spanish-language educational Flutter application for
children who are beginning to learn letters, syllables, words, and simple
sentences. It provides short, visual activities inspired by Montessori
learning principles and combines reading, listening, speaking, handwriting,
and matching exercises in one app.

The project is intended as an educational support tool. It is not a medical,
diagnostic, or therapeutic device.

## Features

- Letter and vowel learning activities.
- Syllable and word practice.
- Sentence reading with visual pictograms.
- Letter, syllable, word, and pictogram matching activities.
- Exercises for completing letters, syllables, and words.
- Audio pronunciation and text-to-speech support.
- Speech recognition activities for words and sentences.
- Handwriting practice using Google ML Kit Digital Ink Recognition.
- Downloading and local caching of pictograms from ARASAAC.
- Portrait-oriented interface designed for use on mobile devices.

## Technology

- [Flutter](https://flutter.dev/)
- Dart 3.9 or newer
- `flutter_tts` for text-to-speech
- `speech_to_text` for speech recognition
- Google ML Kit Digital Ink Recognition for handwriting exercises
- `camera` for camera-based activities
- ARASAAC API for Spanish pictograms

## Requirements

Before running the project, install:

1. [Flutter](https://docs.flutter.dev/get-started/install) with Dart included.
2. Android Studio and an Android SDK for Android development, or the tools
	required by the Flutter desktop/web platform you intend to use.
3. A physical device or emulator. A physical device is recommended for speech,
	camera, and handwriting features.

Verify the local setup with:

```bash
flutter doctor
```

## Getting Started

Clone the repository and enter the Flutter project directory:

```bash
git clone https://github.com/Alexgaby18/App_Montessori.git
cd App_Montessori/my_montessori
```

Install dependencies:

```bash
flutter pub get
```

List available devices and run the application:

```bash
flutter devices
flutter run
```

You can select a specific device with:

```bash
flutter run -d <device-id>
```

## Build Commands

Android APK:

```bash
flutter build apk
```

Android App Bundle:

```bash
flutter build appbundle
```

Web:

```bash
flutter build web
```

The project also contains Flutter platform folders for iOS, macOS, Linux, and
Windows. Some features, especially speech recognition, camera access, and
Google ML Kit handwriting recognition, depend on platform support and must be
tested on the target platform.

## Testing and Analysis

Run the static analyzer:

```bash
flutter analyze
```

Run the test suite:

```bash
flutter test
```

## Project Structure

```text
lib/
  config/                 Application configuration
  core/                   Constants, themes, and shared services
  data/                   External data access, including ARASAAC
  presentation/           Screens, controllers, and reusable widgets
  main.dart               Application entry point
assets/                   Images, SVG files, audio, fonts, and icons
test/                     Flutter and unit tests
android/, ios/, web/      Platform-specific Flutter projects
```

The main learning content and sentence-to-pictogram mappings are maintained
in `lib/core/constans/list_pitogram.dart`. Shared application services are in
`lib/core/services/`, while the ARASAAC integration is in
`lib/data/repositories/arasaac_api.dart`.

## Pictograms and Third-Party Content

Pictograms are obtained at runtime from the
[ARASAAC pictogram API](https://api.arasaac.org/). The app stores downloaded
images in the device's application documents directory so they can be reused
without downloading them again. Internet access is therefore required the
first time a pictogram is requested.

ARASAAC pictograms are provided by the
[Aragonese Center for Augmentative and Alternative Communication (ARASAAC)](https://arasaac.org/),
created by the Government of Aragon. They are distributed under the
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
license (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/).

Attribution:

> Pictograms by ARASAAC (Aragonese Center for Augmentative and Alternative
> Communication), Government of Aragon, used under the CC BY-NC-SA 4.0
> license. Source: https://arasaac.org/

Any redistribution, adaptation, or commercial use of ARASAAC material must
follow the current ARASAAC terms and the CC BY-NC-SA 4.0 license. ARASAAC
content is not owned by this project. The in-app credits also display this
attribution.

Other third-party packages retain their respective licenses. Consult each
package's documentation and the Flutter package metadata before redistributing
the application.

## Software Copyright

Unless a different license is explicitly stated, the application source code,
original artwork, interface design, educational content, and project-specific
assets are copyright © App Montessori contributors. They are not automatically
licensed for copying, modification, or commercial redistribution.

The ARASAAC pictograms and third-party dependencies are separate works and
remain subject to their own licenses. See the in-app Credits dialog for the
current application attribution.

## Privacy and Permissions

The application may request access to features required by its activities,
including the microphone, camera, and handwriting input. Speech recognition
and pictogram downloads may require an internet connection and may involve
platform or service providers outside this project. Review the permission
prompts and the terms of the relevant platform services before deployment.

## Contributing

1. Create a feature branch from the current development branch.
2. Make focused changes and keep educational content in the existing data
	structures when possible.
3. Run `flutter analyze` and `flutter test`.
4. Open a pull request describing the change and the target platform tested.

## Status

This project is under active development. APIs, activities, assets, and
platform support may change as the application evolves.
