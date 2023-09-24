import ballerina/http;
import ballerina/io;

final string BASE_URL = "http://localhost:9090/dsa";

http:Client dsaHttpClient = check new (BASE_URL);

// Create a new lecturer in the system.
public function createLecturer(Lecturer lecturer) returns string|error {
    http:Response resp = check dsaHttpClient->post("/lecturers", lecturer);

    if (resp.statusCode == 201) {
        return "Lecturer created successfully.";
    } else {
        var jsonPayload = resp.getJsonPayload();
        if (jsonPayload is json) {
            return jsonPayload.toString();
        } else {
            return "Error: HTTP " + resp.statusCode.toString();
        }
    }

}

// Fetch all the lecturers from the system.
public function getAllLecturers() returns error|json {
    http:Response resp = check dsaHttpClient->get("/lecturers");
    return resp.getJsonPayload();
}

// Fetch a specific lecturer by their staff number.
public function getLecturerByStaffNumber(string staffNumber) returns error|json {
    http:Response resp = check dsaHttpClient->get("/lecturers/" + staffNumber);
    return resp.getJsonPayload();
}

// Update the details of a specific lecturer by their staff number.
public function updateLecturer(string staffNumber, Lecturer lecturer) returns string|error {
    http:Response|error resp = dsaHttpClient->put("/lecturers/" + staffNumber, lecturer);

    if (resp is http:Response) {
        json|error jsonPayload = resp.getJsonPayload();
        if (jsonPayload is json) {
            return jsonPayload.toString();
        } else {
            return "Error: Failed to retrieve the JSON payload.";
        }
    } else if (resp is error) {
        return "Error: HTTP request failed with message - " + resp.message();
    }
}

// Remove a lecturer from the system using their staff number.
public function deleteLecturer(string staffNumber) returns string|error {
    http:Response|error resp = dsaHttpClient->delete("/lecturers/" + staffNumber);

    if (resp is http:Response) {
        var jsonPayload = resp.getJsonPayload();
        if (jsonPayload is json) {
            return jsonPayload.toJsonString();
        } else {
            return "Error with HTTP status code: " + resp.statusCode.toString();
        }
    } else if (resp is error) {
        return "Error: Failed to execute DELETE request. " + resp.message();
    }
}

// Fetch all lecturers teaching a particular course.
public function getLecturersByCourse(string courseCode) returns error|json {
    http:Response resp = check dsaHttpClient->get("/lecturers/course/" + courseCode);
    return resp.getJsonPayload();
}

// Fetch all lecturers located in a specific office.
// Fetch all lecturers located in a specific office.
public function getLecturersByOffice(string officeNumber) returns error|json {
    http:Response resp = check getResponse("/lecturers/office/" + officeNumber);
    return resp.getJsonPayload();
}

function getResponse(string path) returns http:Response|error {
    return dsaHttpClient->get(path);
}

public type Course record {
    string courseName;
    string courseCode;
    int NQFLevel;
};

public type Lecturer record {
    string staffNumber;
    string officeNumber;
    string staffName;
    string title;
    Course[] courses;
};

public function main() returns error? {
    Lecturer lecturer = {
        staffNumber: "SN001",
        officeNumber: "ON101",
        staffName: "John Smith",
        title: "Dr.",
        courses: [
            {
                courseName: "Data Structures",
                courseCode: "DSA101",
                NQFLevel: 4
            }
        ]
    };

    // Create lecturer
    string|error createResp = createLecturer(lecturer);
    if (createResp is string) {
        io:println(createResp);
    } else {
        io:println("Error creating lecturer:", createResp.message());
    }

    // Fetch all lecturers
    error|json allLecturers = getAllLecturers();
    if (allLecturers is json) {
        if (allLecturers.status == 405) {
            io:println("Error: ", allLecturers.message);
        } else {
            io:println("All lecturers:", allLecturers);
        }
    } else {
        io:println("Error fetching lecturers:", allLecturers.message());
    }
}
