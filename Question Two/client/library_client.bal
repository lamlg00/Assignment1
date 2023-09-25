import ballerina/io;

LibraryClient ep = check new ("http://localhost:9090");

public function main() returns error? {
    AddBookRequest addBookRequest = {book: {title: "ballerina", author_1: "leroy", author_2: "leroy", location: "Shelve 2", ISBN: "BH64G", status: true}};
    AddBookResponse addBookResponse = check ep->AddBook(addBookRequest);
    io:println(addBookResponse);

    UpdateBookRequest updateBookRequest = {book: {title: "ballerina", author_1: "leroy", author_2: "leroy", location: "ballerina", ISBN: "BH64G", status: true}};
    UpdateBookResponse updateBookResponse = check ep->UpdateBook(updateBookRequest);
    io:println(updateBookResponse);

    RemoveBookRequest removeBookRequest = {ISBN: "BH64G"};
    RemoveBookResponse removeBookResponse = check ep->RemoveBook(removeBookRequest);
    io:println(removeBookResponse);

    ListAvailableBooksRequest listAvailableBooksRequest = {};
    ListAvailableBooksResponse listAvailableBooksResponse = check ep->ListAvailableBooks(listAvailableBooksRequest);
    io:println(listAvailableBooksResponse);

    LocateBookRequest locateBookRequest = {ISBN: "BH64G"};
    LocateBookResponse locateBookResponse = check ep->LocateBook(locateBookRequest);
    io:println(locateBookResponse);

    BorrowBookRequest borrowBookRequest = {user_id: "ballerina", ISBN: "BH64G"};
    BorrowBookResponse borrowBookResponse = check ep->BorrowBook(borrowBookRequest);
    io:println(borrowBookResponse);

    User createUsersRequest = {user_id: "ballerina", profile: "STUDENT"};
    CreateUsersStreamingClient createUsersStreamingClient = check ep->CreateUsers();
    check createUsersStreamingClient->sendUser(createUsersRequest);
    check createUsersStreamingClient->complete();
    CreateUsersResponse? createUsersResponse = check createUsersStreamingClient->receiveCreateUsersResponse();
    io:println(createUsersResponse);
}

