import ballerina/grpc;

listener grpc:Listener ep = new (9090);

    // Use in-memory maps for storage.
    map<Book> books = {};
    map<User> users = {};  

@grpc:Descriptor {value: BUF_DESC}
service "Library" on ep {

    remote function AddBook(AddBookRequest value) returns AddBookResponse|error {
        Book book = value.book;
        books[book.ISBN] = book;
        return {ISBN: book.ISBN};
    }
    
    remote function UpdateBook(UpdateBookRequest value) returns UpdateBookResponse|error {
        Book book = value.book;
        if (books.hasKey(book.ISBN)) {
            books[book.ISBN] = book;
            return {status: "Success"};
        } else {
            return {status: "Book not found"};
        }
    }

    remote function RemoveBook(RemoveBookRequest value) returns RemoveBookResponse|error {
        string ISBN = value.ISBN;
        Book? bookToRemove = books.remove(ISBN);
        if (bookToRemove is Book) {
            return {books: [bookToRemove]};
        } else {
            return {books: []};
        }
    }

    remote function ListAvailableBooks(ListAvailableBooksRequest value) returns ListAvailableBooksResponse|error {
        Book[] availableBooksArray = [];
        foreach string key in books.keys() {
            Book b = <Book>books[key];
            if (b.status) {
                availableBooksArray.push(b);
            }
        }
        return {books: availableBooksArray};
    }


    remote function LocateBook(LocateBookRequest value) returns LocateBookResponse|error {
        string ISBN = value.ISBN;
        Book? book = books[ISBN];
        if (book is Book) {
            return {location: book.location, status: book.status};
        } else {
            return error("Book not found");
        }
    }

    remote function BorrowBook(BorrowBookRequest value) returns BorrowBookResponse|error {
        string ISBN = value.ISBN;
        Book? potentialBook = books[ISBN];

        if (potentialBook is Book) {
            if (potentialBook.status) {
                potentialBook.status = false;
                books[ISBN] = potentialBook;
                return {status: "Borrowed successfully"};
            } else {
                return {status: "Book already borrowed"};
            }
        } else {
            return {status: "Book not found"};
        }
    }


    remote function CreateUsers(stream<User, grpc:Error?> clientStream) returns CreateUsersResponse|error {
        error? e = clientStream.forEach(function(User user) {
            users[user.user_id] = user;
        });
        if (e is error) {
            return {status: "Error creating users"};
        } else {
            return {status: "Success"};
        }
    }
}

