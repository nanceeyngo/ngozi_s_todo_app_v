import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ngozi_s_todo_app_v/todo_app/controllers/add_todo_controller.dart';
import 'package:ngozi_s_todo_app_v/todo_app/controllers/mock_controller.dart';
import 'package:ngozi_s_todo_app_v/todo_app/controllers/todo_controller.dart';
import 'package:ngozi_s_todo_app_v/todo_app/repositories/todo_repository.dart';
import 'package:ngozi_s_todo_app_v/todo_app/services/todo_notification_service.dart';


class TodDoBindings extends Bindings{
  @override
  void dependencies() {
    _injectMockController();
    _injectRepository();
    _injectController();
    _injectAddTodoController();
  }

  // Future<void> _initHive() async{
  //   await Hive.initFlutter();
  //   await Hive.openBox('todos');
  // }

  void _injectRepository(){
    Get.lazyPut<TodoRepository>(
            () => TodoRepoImpl(box: Hive.box('todos')),
        fenix: true //re-create if removed from memory
    );
  }

  // Future<void> _injectNotificationService() async{
  //   final notificationService = TodoNotificationServiceImpl();
  //   await notificationService.init();
  //   Get.put<TodoNotificationService>(notificationService, permanent: true);
  // }

  void _injectController(){
    Get.lazyPut<TodoController>(
            () => TodoControllerImpl(
            repo: Get.find<TodoRepository>(),
            //notificationService: TodoNotificationServiceImpl()
            notificationService: Get.find<TodoNotificationService>()
        ),
        fenix: true
    );
  }

  void _injectAddTodoController(){
    Get.lazyPut<AddTodoController>(
        () => AddTodoControllerImpl(),
      fenix: true
    );
  }
  
  void _injectMockController(){
    Get.lazyPut(() => MockTodoController());
  }

}