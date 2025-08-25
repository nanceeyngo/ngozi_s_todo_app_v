import 'package:flutter/material.dart';
import 'package:ngozi_s_todo_app_v/todo_app/controllers/add_todo_controller.dart';
import 'package:ngozi_s_todo_app_v/todo_app/controllers/todo_controller.dart';
import 'package:ngozi_s_todo_app_v/todo_app/models/todo.dart';
import '../../utils/colors.dart';
import '../../utils/fonts.dart';
import 'package:get/get.dart';

class AddTodoPage extends StatelessWidget {
  const AddTodoPage({super.key, this.parent});

  final Todo? parent;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoController>();
    final addTodoController = Get.find<AddTodoController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Todo',
          style: s26w700.copyWith(color: AppColors.textPrimary),)
      ),
      body: FocusScope(
        node: FocusScopeNode(),
        child: GestureDetector(
          onTap: () {
            // Dismiss the keyboard when tapping outside the text fields
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: ListView(
              children: [
                //Title(required)
                TextField(
                  controller: addTodoController.titleController,
                  decoration: InputDecoration(
                    label: Row(
                      children: [
                        Text('Todo Title', style: s18w400),
                        Text('*', style: s20w400.copyWith(color: AppColors.error)),
                      ],
                    )
                    ),
                  maxLines: 2,
                  ),
                SizedBox(height: 20,),
                //Description(optional)
                TextField(
                  controller: addTodoController.descriptionController,
                  decoration: InputDecoration(
                    label: Text('Description of Todo', style: s18w400)
                  ),
                  maxLines: 4,
                ),
                SizedBox(height: 20,),

                //Deadline picker
                Obx(()=> ListTile(
                  title: Text(
                    addTodoController.deadline.value == null?
                        'No Deadline'
                        : 'Deadline: ${addTodoController.deadline.value?.toLocal()}',
                    style: s18w400,
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async{
                    //step 1: pick the date
                    final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100)
                    );

                    if (pickedDate == null) return;

                    //Check before using context again
                    if (!context.mounted) return;

                      //step 2: pick the time
                      final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now()
                      );
                      if(pickedTime != null){
                        //step 3: merge date and time
                        final fullDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute
                        );
                        addTodoController.deadline.value = fullDateTime;
                      }
                    }
                )),
                SizedBox(height: 20,),
                Obx((){
                  final currentReminder = addTodoController.reminder.value;
                  return Row(
                    children: [
                      Text('Remind me', style: s18w400),
                      Expanded(
                          child: Slider(
                              min: 0,
                              max: 180,
                              divisions: 12,
                              label: currentReminder == null || currentReminder.inMinutes == 0 ?
                              'Off' : '${currentReminder.inMinutes} min before',
                              value: (currentReminder?.inMinutes ?? 0).toDouble(),
                              onChanged: addTodoController.deadline.value == null? null
                                  : (v) {
                                final minutes = v.toInt();
                                addTodoController.reminder.value = minutes == 0? null
                                    : Duration(minutes: minutes);
                              }
                          )
                      )
                    ],
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
