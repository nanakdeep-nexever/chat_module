/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:metadata/metadata.dart';

class CustomTextFieldWithLinkPreview extends StatefulWidget {
  @override
  _CustomTextFieldWithLinkPreviewState createState() =>
      _CustomTextFieldWithLinkPreviewState();
}

class _CustomTextFieldWithLinkPreviewState
    extends State<CustomTextFieldWithLinkPreview> {
  final TextEditingController _controller = TextEditingController();
  bool isValidLink = false;
  Metadata? linkMetadata;

  // Regular expression to check if the input is a valid URL
  final RegExp urlRegExp = RegExp(
    r'^(https?|ftp)://[^\s/$.?#].[^\s]*$',
    caseSensitive: false,
  );

  void initState() {
    super.initState();

    // Listen to changes in the text field
    _controller.addListener(() {
      final text = _controller.text;

      // Check if the text matches the URL pattern
      if (urlRegExp.hasMatch(text)) {
        _fetchLinkMetadata(text); // Fetch metadata if the URL is valid
      } else {
        setState(() {
          isValidLink = false;
          linkMetadata = null; // Clear metadata if the URL is not valid
        });
      }
    });
  }

  // Fetch metadata using metadata_fetch package
  Future<void> _fetchLinkMetadata(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Metadata? metadata = MetadataFetch.extract(response.body);
        if (metadata != null) {
          setState(() {
            linkMetadata = metadata;
            isValidLink = true;
          });
        }
      }
    } catch (e) {
      print('Failed to fetch metadata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter a link',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          SizedBox(height: 16),
          // Display link preview when URL is valid
          if (isValidLink && linkMetadata != null)
            _buildLinkPreview(linkMetadata!)
        ],
      ),
    );
  }

  // Widget to build the link preview
  Widget _buildLinkPreview(Metadata metadata) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (metadata.image != null)
              Image.network(
                metadata.image!,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            if (metadata.title != null)
              Text(
                metadata.title!,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            if (metadata.description != null)
              Text(
                metadata.description!,
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Link Preview TextField')),
      body: CustomTextFieldWithLinkPreview(),
    ),
  ));
}
*/
