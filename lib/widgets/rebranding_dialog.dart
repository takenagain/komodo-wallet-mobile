import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RebrandingDialog extends StatefulWidget {
  final bool showCloseButton;

  const RebrandingDialog({this.showCloseButton = true});

  @override
  _RebrandingDialogState createState() => _RebrandingDialogState();
}

class _RebrandingDialogState extends State<RebrandingDialog> {
  bool _canClose = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _canClose = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return _canClose;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.grey.shade200,
        child: dialogContent(context),
      ),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 16, right: 16, top: 36, bottom: 8),
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 10.0)),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: SvgPicture.asset('assets/rebranding/old_logo.svg'),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset('assets/rebranding/arrow.svg',
                          color: Colors.black),
                    ),
                  ),
                  Flexible(
                    child: SvgPicture.asset('assets/rebranding/new_logo.svg'),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Text(
                  "It's a new era! We have officially changed our name from 'AtomicDEX' to 'Komodo Wallet'"),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () async {
                    const url = 'https://google.com/';
                    await canLaunchUrlString(url)
                        ? await launchUrlString(url)
                        : throw Exception(
                            'Could not launch "Official press release" URL');
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Official press release',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.showCloseButton && _canClose)
          Positioned(
            top: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: _canClose
                    ? () {
                        Navigator.of(context).pop();
                      }
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
