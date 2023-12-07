# data_save

With this library, you can find your information in
SharedPreferences
and save browser cache
Optimized for all operating systems

## Getting Started

# Installing
`Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Utils.dbInit();
    runApp(MaterialApp(home: MyApp()));
}`

# use
Save
</br>
`DataSave.setString("key","my value");`
</br>
</br>
Get Value
</br>
`String? value=DataSave.getString("key");`
