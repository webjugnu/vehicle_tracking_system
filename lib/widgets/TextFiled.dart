import 'package:flutter/material.dart';
class TextFiled extends StatelessWidget {
  final String? labelAndHint;
  final String? keyboardType;
  final Icon? suffix;
  final Icon? prefixIcon;
  final int? maxLength;
  final int? minLength;
  final String? minValidateMsg;
  final dynamic saved;
  final String? initialValue;
  const TextFiled({Key? key,this.labelAndHint,this.keyboardType,this.prefixIcon,this.suffix,this.maxLength,this.minLength,this.minValidateMsg,this.saved,this.initialValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType == 'number' ?TextInputType.number:null,
      textCapitalization: TextCapitalization.characters,
      // autofocus: true,
      textInputAction: TextInputAction.next,
      maxLength: maxLength,
      initialValue: initialValue,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffix,
        hintText: labelAndHint,
        labelText: labelAndHint,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      ),
      onSaved: saved,
      validator: (value){
        if(value!.isEmpty){
          return "";
        }else if(value.length < minLength!){
          return minValidateMsg;
        }else{
          return null;
        }
      },
    );
  }
}