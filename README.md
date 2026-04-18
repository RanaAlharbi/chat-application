

The purpose of this assessment is to evaluate your ability to design and implement a real-time chat application using **Flutter**, **Bloc**, and **Supabase**.  
You will develop a **Chat Application (Lab)** that supports both **private messaging** and **group conversations**. The project focuses on mastering **state management**, **real-time database communication**, and **clean architecture design**.

---

## **2\. Project Concept**

A real-time chat application that allows users to:

* Create an account.  
* Send and receive messages in **private chats** and **group chats**.  
* Delete messages for everyone within a 24-hour time limit.

Each user can only access their own conversations or groups they are part of.  
Messages and users are synced in real-time using **Supabase**.

---

## **3\. Core Technical Requirements**

To successfully complete this project, you must use the following technologies:

| Component | Requirement |
| ----- | ----- |
| Programming Language | Dart |
| Framework | Flutter |
| State Management | Flutter Bloc |
| Backend as a Service (BaaS) | Supabase |

---

## **4\. Required Features List**

The project is divided into three levels of features.  
Completing the **Basic** and **Intermediate** levels is **mandatory**, while the **Advanced** level is **optional** for extra credit.

---

### **Basic Level (60% of grade)**

#### **Authentication**

* Sign Up screen using email and password.  
* Sign In screen for existing users.  
* Sign Out functionality.

#### **Private Chat**

* Two users can exchange messages in real-time.  
* Messages should display sender, timestamp, and text content.

#### **Group Chat**

* Users can create and join group chats.  
* Messages inside groups are visible to all members.

#### **Send & Display Messages**

* Main chat screen displaying messages in chronological order.  
* Support for real-time message updates using Supabase streams.

#### **Delete Message**

* A user can delete a message for everyone only if the message is **less than 24 hours old**.  
* Deleted messages should display a placeholder (e.g., *“Message deleted”*).

---

### **Intermediate Level (30% of grade)**

#### **Edit Message**

* Users can edit their own messages (within 24 hours).

#### **User Presence**

* Display online/offline status for each user in chat lists.

#### **UI State Management**

All UI states must be managed via **Bloc**, including:

* **Loading:** fetching or sending data.  
* **Success:** operation completed successfully.  
* **Error:** operation failed with a clear message.

#### **Clean UI & Navigation**

* Clear separation between **private** and **group** chat sections.  
* Simple, intuitive, and user-friendly design.

---

### **Advanced Level (10% of grade \- Optional)**

#### **Message Reactions**

* Allow users to react to messages with emojis (e.g., 👍 ❤️ 😂).

#### **Typing Indicators**

* Display “User is typing...” in real-time.

#### **Read Receipts**

* Indicate when a message has been seen by the receiver or all group members.

#### **Push Notifications**

* Integrate **Firebase Cloud Messaging (FCM)** to notify users of new messages when the app is closed.

---

## **5\. Supabase Setup**

Create a new project in **Supabase**, and configure the following tables using the SQL editor:

### **users**

| Column | Type | Constraints |
| ----- | ----- | ----- |
| id | uuid | Primary Key, default `uuid_generate_v4()` |
| username | text | Not Null, Unique |
| avatar\_url | text |  |
| created\_at | timestamptz | default `now()` |

### **groups**

| Column | Type | Constraints |
| ----- | ----- | ----- |
| id | uuid | Primary Key, default `uuid_generate_v4()` |
| name | text | Not Null |
| created\_at | timestamptz | default `now()` |

### **group\_members**

| Column | Type | Constraints |
| ----- | ----- | ----- |
| id | uuid | Primary Key, default `uuid_generate_v4()` |
| group\_id | uuid | Foreign Key referencing `groups(id)` |
| user\_id | uuid | Foreign Key referencing `users(id)` |
| joined\_at | timestamptz | default `now()` |

### **messages**

| Column | Type | Constraints |
| ----- | ----- | ----- |
| id | uuid | Primary Key, default `uuid_generate_v4()` |
| sender\_id | uuid | Foreign Key referencing `users(id)` |
| receiver\_id | uuid | Nullable — used for private chat |
| group\_id | uuid | Nullable — used for group chat |
| content | text | Not Null |
| deleted\_for\_all | boolean | default `false` |
| created\_at | timestamptz | default `now()` |

