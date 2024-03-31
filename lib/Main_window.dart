import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'functions/voice_generation.dart';

class Main_window extends StatefulWidget {
  const Main_window({super.key});

  @override
  State<Main_window> createState() => _Main_windowState();
}

class _Main_windowState extends State<Main_window> {
  TextEditingController api_key_controller = TextEditingController();
  TextEditingController text_generate = TextEditingController();
  bool api_key_obsecure = false;
  var value_models;
  var value_voices;
  List<DropdownMenuItem> dropdown_list = [];
  bool api_key_empty = false;
  bool text_input_empty = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Api Key: ",style: TextStyle(fontFamily: "Roboto",fontWeight: FontWeight.w700,fontSize: MediaQuery.of(context).size.width * 0.02),textAlign: TextAlign.start,),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.08,
                  child: TextField(
                    controller: api_key_controller,
                    obscureText: api_key_obsecure,
                    style: TextStyle(fontFamily: "Roboto",fontWeight: FontWeight.w600,fontSize: MediaQuery.of(context).size.width * 0.015),
                    onChanged: (f) {
                      setState(() {
                        api_key_empty = false;
                        context.read<voice_generation>().api_key_is_wrong = false;
                      });
                    },
                    decoration: InputDecoration(
                        hintText: "Api Key",
                        contentPadding: EdgeInsets.all(10),
                      error: api_key_empty || context.watch<voice_generation>().api_key_is_wrong ?
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(PhosphorIcons.warning(),color: Theme.of(context).colorScheme.error,),
                              ),
                              Text(api_key_empty ? "must not be empty!" : context.watch<voice_generation>().api_key_is_wrong ?  "Api Key is wrong!": "" ,style: TextStyle(fontFamily: "Roboto",color: Theme.of(context).colorScheme.error,fontWeight: FontWeight.w700,fontSize: MediaQuery.of(context).size.width * 0.015),textAlign: TextAlign.start,),

                            ],
                          )
                          : null
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          api_key_obsecure = !api_key_obsecure;
                        });
                      },
                      icon: Icon(api_key_obsecure ? PhosphorIcons.eyeSlash(): PhosphorIcons.eye() )),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0,right: 8),
                  child: Text("Model: ",style: TextStyle(fontFamily: "Roboto",fontWeight: FontWeight.w700,fontSize: MediaQuery.of(context).size.width * 0.02),textAlign: TextAlign.start,),
                ),
                DropdownButton(
                    items: context.watch<voice_generation>().dropdown_list_models,
                    value: value_models,
                    onChanged: (value_) {
                     setState(() {
                       value_models = value_;
                     });
                    })
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0,right: 8),
                  child: Text("Voices: ",style: TextStyle(fontFamily: "Roboto",fontWeight: FontWeight.w700,fontSize: MediaQuery.of(context).size.width * 0.02),textAlign: TextAlign.start,),
                ),
                DropdownButton(
                    items: context.watch<voice_generation>().dropdown_list_voices,
                    value: value_voices,
                    onChanged: (value_) {
                      setState(() {
                        value_voices = value_;
                      });
                    })
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      if(api_key_controller.text.isNotEmpty) {
                        context.read<voice_generation>().get_models(context,api_key_controller.text);
                      }
                      else {
                        setState(() {
                          api_key_empty = true;
                        });
                      }
                    },
                    child: Text("Load models",style: TextStyle(fontFamily: "Roboto",fontWeight: FontWeight.w700,fontSize: MediaQuery.of(context).size.width * 0.02),textAlign: TextAlign.start,)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.1,
              child: TextField(
                controller: text_generate,
                maxLines: 10,
                style: TextStyle(fontFamily: "Roboto",fontWeight: FontWeight.w600,fontSize: MediaQuery.of(context).size.width * 0.015),
                onChanged: (f) {
                  setState(() {
                    text_input_empty = false;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Text input",
                    contentPadding: EdgeInsets.all(10),
                    error: text_input_empty ?
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(PhosphorIcons.warning(),color: Theme.of(context).colorScheme.error,),
                        ),
                        Text(text_input_empty ? "must not be empty!" : "" ,style: TextStyle(fontFamily: "Roboto",color: Theme.of(context).colorScheme.error,fontWeight: FontWeight.w700,fontSize: MediaQuery.of(context).size.width * 0.015),textAlign: TextAlign.start,),

                      ],
                    )
                        : null
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(onPressed: () {
             if (api_key_controller.text.isNotEmpty) {
               if (text_generate.text.isNotEmpty) {
                 context.read<voice_generation>().generate(api_key_controller.text, value_voices,value_models, text_generate.text);
               } else {
                 setState(() {
                   text_input_empty = true;
                 });
               }
             } else {
               setState(() {
                 api_key_empty = true;
               });
             }
            }, child: Text("Generate",style: TextStyle(fontFamily: "Roboto",fontWeight: FontWeight.w700,fontSize: MediaQuery.of(context).size.width * 0.025),textAlign: TextAlign.center,),),
          )
        ],
      ),
    );
  }
  @override
void initState()  {
    // TODO: implement initState
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (context.read<voice_generation>().dropdown_list_models.isNotEmpty && value_models == null) {
        setState(() {
          value_models = context.read<voice_generation>().dropdown_list_models[0].value;
        });
      }
      if (context.read<voice_generation>().dropdown_list_voices.isNotEmpty && value_voices == null) {
        setState(() {
          value_voices = context.read<voice_generation>().dropdown_list_voices[0].value;
        });
      }
    });
  }
}
