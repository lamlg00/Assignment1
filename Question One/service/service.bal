import ballerina/http;
import ballerina/log;

type Course record {
    string courseName;
    string courseCode;
    int NQFLevel;
};

type Lecturer record {
    string staffNumber;
    string officeNumber;
    string staffName;
    string title;
    Course[] courses;
};

//use map for in-app memory
map<Lecturer> lecturersMap = {};

function createErrorResponse(string message) returns json {
    return {status: "error", message: message, data: {}};
}

function handleResponse(http:Caller caller, json response) returns error? {
    var result = caller->respond(response);
    if (result is error) {
        log:printError("Failed to send response", result);
    }
    return result;
}

service /dsa on new http:Listener(9090) {

    resource function post lecturers(http:Caller caller, http:Request req) returns error? {
        json|error potentialJSON = req.getJsonPayload();

        if (potentialJSON is error) {
            json errorResponse = {status: "error", message: "Bad JSON", data: {}};
            check caller->respond(errorResponse);
            return;
        }

        Lecturer|error maybeLecturer = potentialJSON.cloneWithType(Lecturer);
        if (maybeLecturer is error) {
            json errorResponse = {status: "error", message: "Bad Lecturer JSON", data: {}};
            check caller->respond(errorResponse);
            return;
        }

        if (lecturersMap.hasKey(maybeLecturer.staffNumber)) {
            json errorResponse = {status: "error", message: "Lecturer exists", data: {}};
            check caller->respond(errorResponse);
            return;
        }

        lecturersMap[maybeLecturer.staffNumber] = maybeLecturer;

        json successResponse = {
            status: "success",
            message: "Added!",
            data: maybeLecturer.toJson()
        };
        check caller->respond(successResponse);

    }


    //get all lecturers from storage
    resource function get lecturers(http:Caller caller) returns error? {
        json[] lecturerList = [];
        foreach var [_, lecturer] in lecturersMap.entries() {
            lecturerList.push(lecturer.toJson());
        }
        
        if (lecturerList.length() > 0) {
            return handleResponse(caller, {status: "success", message: "Got all lecturers", data: lecturerList});
        } else {
            return handleResponse(caller, createErrorResponse("No lecturers found"));
        }
    }


    resource function get lecturers/[string staffNumber](http:Caller caller) returns error? {
        if (lecturersMap.hasKey(staffNumber)) {
            Lecturer theLecturer = <Lecturer>lecturersMap[staffNumber];
            return handleResponse(caller, {status: "success", message: "Got one", data: theLecturer.toJson()});
        } else {
            return handleResponse(caller, createErrorResponse("Can't find"));
        }
    }



    resource function put lecturers/[string staffNumber](http:Caller caller, http:Request req) returns error? {
        var maybeJSON = req.getJsonPayload();
        if (maybeJSON is error) {
            return handleResponse(caller, createErrorResponse("Bad JSON"));
        }

        var newLecturerResult = maybeJSON.cloneWithType(Lecturer);
        if (newLecturerResult is error) {
            return handleResponse(caller, createErrorResponse("Bad Lecturer JSON"));
        }

        if (lecturersMap.hasKey(staffNumber)) {
            lecturersMap[staffNumber] = <Lecturer>newLecturerResult;
            return handleResponse(caller, {status: "success", message: "Updated"});
        } else {
            return handleResponse(caller, createErrorResponse("Can't find to update"));
        }
    }

    resource function delete lecturers/[string staffNumber](http:Caller caller) returns error? {
        if (lecturersMap.hasKey(staffNumber)) {
            _ = lecturersMap.remove(staffNumber);
            return handleResponse(caller, {status: "success", message: "Removed: " + staffNumber});
        } else {
            return handleResponse(caller, createErrorResponse("Can't find to remove: " + staffNumber));
        }
    }

    resource function get lecturers/course/[string courseCode](http:Caller caller) returns error? {
        Lecturer[] lecturersWithCourse = [];
        foreach var [_, possibleLecturer] in lecturersMap.entries() {
            foreach var course in possibleLecturer.courses {
                if (course.courseCode == courseCode) {
                    lecturersWithCourse.push(possibleLecturer);
                    break;
                }
            }
        }

        if (lecturersWithCourse.length() > 0) {
            json[] jsonArray = [];
            foreach var lecturer in lecturersWithCourse {
                jsonArray.push(lecturer.toJson());
            }
            return handleResponse(caller, {status: "success", message: "Got em for course", data: jsonArray});
        } else {
            return handleResponse(caller, createErrorResponse("None for course"));
        }
    }

    resource function get lecturers/office/[string officeNumber](http:Caller caller) returns error? {
        Lecturer[] officeLecturers = [];
        foreach var [_, possibleLecturer] in lecturersMap.entries() {
            if (possibleLecturer.officeNumber == officeNumber) {
                officeLecturers.push(possibleLecturer);
            }
        }

        if (officeLecturers.length() > 0) {
            json[] lecturerJsonArr = [];
            foreach var lecturer in officeLecturers {
                lecturerJsonArr.push(lecturer.toJson());
            }
            return handleResponse(caller, {status: "success", message: "Got em for office", data: lecturerJsonArr});
        } else {
            return handleResponse(caller, createErrorResponse("None for office"));
        }
    }
}

public function main() returns error? {
    // this starts the service on port 9090
}