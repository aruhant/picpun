import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionNumber extends StatefulWidget {
  const VersionNumber({Key? key, this.message = ''}) : super(key: key);

  final String message;
  @override
  _VersionNumberState createState() => _VersionNumberState();
}

class _VersionNumberState extends State<VersionNumber> {
  String _versionNumber = '';

  @override
  void initState() {
    super.initState();
    _getVersionNumber();
  }

  Future<void> _getVersionNumber() async {
    final version = await _getVersion();
    if (mounted) {
      setState(() {
        _versionNumber = version;
      });
    }
  }

  Future<String> _getVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('${widget.message}\n$_versionNumber',
          style: const TextStyle(fontSize: 12, color: Colors.black45)),
    );
  }
}
