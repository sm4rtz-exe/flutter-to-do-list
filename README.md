# to_do_list

A flutter project I am doing for learning flutter framework.

## Features of this project
- Create to do items, add text to item header and description.
- Read to do items.
- Update to do items header and description. And check finished items.
- Delete to do items.

## Dependencies
- **[sqflite](https://pub.dev/packages/sqflite)** - SQLite plugin for Flutter (Local Database)
- **[path](https://pub.dev/packages/path)** - Utilities for managing filesystem paths

## How to run this project?

To run this project locally, follow these steps:

### Prerequisites
- Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (version compatible with your environment)
- An Android/iOS Emulator or physical device connected

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/sm4rtz-exe/flutter-to-do-list.git
   cd flutter-to-do-list
   flutter pub get
   flutter run
   ```

## What have I learned?
### Local DB
In this project, I've learned the flow of creating and connecting a local database to the app. Here's the flow I understand.
- Create a data model (Only data blueprints and functions that import and export data into other formats, such as a Dart instance)
- Create a database service (CRUD operations: the parts where sql query is actually connect to the db)

### async and await keywords
- These keywords tell a function that variables inside them do not yet have values and need to wait until the value is assigned before continuing to the next line, such as waiting for the app to connect to the DB and get the value into the variable before doing the next command. Without this keyword, the app could crash because it cannot find the value inside the variable. This ensures data is fully retrieved before proceeding.
