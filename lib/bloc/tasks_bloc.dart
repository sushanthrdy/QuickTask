
import 'dart:async';
import 'dart:io';

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:quick_task/model/task_model.dart';
import 'package:quick_task/network/api_response.dart';
import 'package:quick_task/repository/tasks_repository.dart';
import 'package:quick_task/utils/app_string.dart';

class TasksBloc {
  late TaskRepository _taskRepository;

  StreamController<ApiResponse<ParseResponse>>? _taskController;
  StreamController<ApiResponse<Map<String, dynamic>>>? _taskFetchController;
  StreamController<int>? _inProgressCountController;
  StreamController<int>? _completedCountController;
  StreamController<int>? _inCompletedCountController;

  TasksBloc() {
    _taskRepository = TaskRepository();

    _taskController =
    StreamController<ApiResponse<ParseResponse>>.broadcast();
    _taskFetchController =
    StreamController<ApiResponse<Map<String, dynamic>>>.broadcast();
    _inProgressCountController = StreamController<int>();
    _completedCountController = StreamController<int>();
    _inCompletedCountController = StreamController<int>();
  }

  Stream<ApiResponse<ParseResponse>>? getTaskResponse(){
    return _taskController?.stream as Stream<ApiResponse<ParseResponse>>;
  }

  Stream<ApiResponse<Map<String, dynamic>>>? getFetchTaskResponse(){
    return _taskFetchController?.stream as Stream<ApiResponse<Map<String, dynamic>>>;
  }

  Stream<int>? getInProgressCount(){
    return _inProgressCountController?.stream as Stream<int>?;
  }

  Stream<int>? getCompletedCount(){
    return _completedCountController?.stream as Stream<int>?;
  }

  Stream<int>? getInCompleteCount(){
    return _inCompletedCountController?.stream as Stream<int>?;
  }

  updateTaskCounts(int pendingCount,int completeCount,int inCompleteCount){
    _inProgressCountController?.sink.add(pendingCount);
    _inCompletedCountController?.sink.add(inCompleteCount);
    _completedCountController?.sink.add(completeCount);
  }

  saveTask(TaskModel task) async{
    _taskController?.sink.add(ApiResponse.loading(AppString.loaderMessage));
    try{
      final response = await _taskRepository.saveTask(task);
      if(response.success) {
        _taskController?.sink.add(ApiResponse.success(response));
      }else{
        if(response.error?.code==-1){
          _taskController?.sink.add(
              ApiResponse.error(AppString.noInternetMsg));
        }else {
          _taskController?.sink.add(
              ApiResponse.error(response.error?.message));
        }
      }
    }on SocketException{
      _taskController?.sink.add(ApiResponse.error(AppString.noInternetMsg));
    }catch(e){
      _taskController?.sink.add(ApiResponse.error(AppString.somethingWentWrongMsg));
    }
  }

  fetchTasks(String status) async{
    _taskFetchController?.sink.add(ApiResponse.loading(AppString.loaderMessage));
    try{
      final response = await _taskRepository.fetchTasks(status);
      if(response["tasks"].success) {
        final inProgressCount = response["inProgress"] ?? 0;
        final completedCount = response["completed"] ?? 0;
        final inCompleteCount = response["incomplete"] ?? 0;
        updateTaskCounts(inProgressCount, completedCount, inCompleteCount);
        _taskFetchController?.sink.add(ApiResponse.success(response));
      }else{
        if(response["tasks"].error?.code==-1){
          _taskFetchController?.sink.add(
              ApiResponse.error(AppString.noInternetMsgWithRefresh));
        }else {
          _taskFetchController?.sink.add(
              ApiResponse.error(response["tasks"].error?.message??""+" Please try refreshing."));
        }
      }
    }on SocketException{
      _taskFetchController?.sink.add(ApiResponse.error(AppString.noInternetMsgWithRefresh));
    }catch(e){
      _taskFetchController?.sink.add(ApiResponse.error(AppString.somethingWentWrongMsgWithRefresh));
    }
  }

  deleteTask(String taskId) async{
    _taskController?.sink.add(ApiResponse.loading(AppString.loaderMessage));
    try{
      final response = await _taskRepository.deleteTask(taskId);
      if(response.success) {
        _taskController?.sink.add(ApiResponse.success(response));
      }else{
        if(response.error?.code==-1){
          _taskController?.sink.add(
              ApiResponse.error(AppString.noInternetMsg));
        }else {
          _taskController?.sink.add(
              ApiResponse.error(response.error?.message));
        }
      }
    }on SocketException{
      _taskController?.sink.add(ApiResponse.error(AppString.noInternetMsg));
    }catch(e){
      _taskController?.sink.add(ApiResponse.error(AppString.somethingWentWrongMsg));
    }
  }

  updateTaskCompletion(String taskId,bool isCompleted) async{
    _taskController?.sink.add(ApiResponse.loading(AppString.loaderMessage));
    try{
      final response = await _taskRepository.updateTaskCompletion(taskId,isCompleted);
      if(response.success) {
        _taskController?.sink.add(ApiResponse.success(response));
      }else{
        if(response.error?.code==-1){
          _taskController?.sink.add(
              ApiResponse.error(AppString.noInternetMsg));
        }else {
          _taskController?.sink.add(
              ApiResponse.error(response.error?.message));
        }
      }
    }on SocketException{
      _taskController?.sink.add(ApiResponse.error(AppString.noInternetMsg));
    }catch(e){
      _taskController?.sink.add(ApiResponse.error(AppString.somethingWentWrongMsg));
    }
  }

  updateTask(TaskModel task) async{
    _taskController?.sink.add(ApiResponse.loading(AppString.loaderMessage));
    try{
      final response = await _taskRepository.updateTask(task);
      if(response.success) {
        _taskController?.sink.add(ApiResponse.success(response));
      }else{
        if(response.error?.code==-1){
          _taskController?.sink.add(
              ApiResponse.error(AppString.noInternetMsg));
        }else {
          _taskController?.sink.add(
              ApiResponse.error(response.error?.message));
        }
      }
    }on SocketException{
      _taskController?.sink.add(ApiResponse.error(AppString.noInternetMsg));
    }catch(e){
      _taskController?.sink.add(ApiResponse.error(AppString.somethingWentWrongMsg));
    }
  }

  dispose(){
    _taskController?.close();
    _taskFetchController?.close();
    _inProgressCountController?.close();
  }
}
