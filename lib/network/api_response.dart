
class ApiResponse<T>{

  Status status;
  T? data;
  String? message;

  ApiResponse.loading(this.message) : status = Status.LOADING;
  ApiResponse.success(this.data) : status = Status.SUCCESS;
  ApiResponse.error(this.message) : status = Status.ERROR;
}

enum Status{LOADING, SUCCESS, ERROR}