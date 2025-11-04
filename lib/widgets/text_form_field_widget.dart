import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatefulWidget {
  const TextFormFieldWidget({
    super.key,
    this.controller,
    required this.hintText,
    required this.iconData,
    required this.validator,
    this.isPassword = false,
    this.isLabel = false,
    this.keyboardType,
    this.label,
    this.onTap,
  });

  final TextEditingController? controller;
  final String hintText;
  final String? label;
  final IconData iconData;
  final String? Function(String?) validator;
  final bool isPassword;
  final bool isLabel;
  final TextInputType? keyboardType;
  final void Function()? onTap;

  @override
  State<TextFormFieldWidget> createState() => _TextFormFieldWidgetState();
}

class _TextFormFieldWidgetState extends State<TextFormFieldWidget> {
  ///
  late bool obscure;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    obscure = widget.isPassword;
  }

  ///
  @override
  Widget build(BuildContext context) {
    return TextFormField(

      onTap: widget.onTap,
      //
      controller: widget.controller,
      //
      validator: widget.validator,
      //
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      //
      cursorColor: Theme.of(context).colorScheme.primary,
      //
      obscureText: obscure,
      //
      keyboardType: widget.keyboardType,
      //
      textCapitalization: TextCapitalization.sentences,
      //
      autocorrect: false,
      //
      enableSuggestions: true,
      //
      decoration: InputDecoration(
        labelText: widget.isLabel ? widget.label : null,
        //
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        //
        prefixIcon: Icon(
          widget.iconData,
          color: Colors.grey,
        ),
        //
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    obscure = !obscure;
                  });
                },
                icon: obscure
                    ? Icon(
                        CupertinoIcons.eye,
                        color: Theme.of(context).colorScheme.onSurface,
                      )
                    : Icon(
                        CupertinoIcons.eye_slash,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
              )
            : null,
        //
        hintText: widget.hintText,
        hintStyle: Theme.of(context).textTheme.titleMedium!
            .copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
        //
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(90),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        //
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(90),
          borderSide: BorderSide(
            width: 0.5,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
        //
      ),
    );
  }
}
