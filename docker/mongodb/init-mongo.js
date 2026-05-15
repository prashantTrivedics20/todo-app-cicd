// MongoDB initialization script
db = db.getSiblingDB('todoapp');

// Create a user for the todoapp database
db.createUser({
  user: 'todouser',
  pwd: 'todopass123',
  roles: [
    {
      role: 'readWrite',
      db: 'todoapp'
    }
  ]
});

// Create indexes for better performance
db.todos.createIndex({ "completed": 1, "createdAt": -1 });
db.todos.createIndex({ "dueDate": 1 });
db.todos.createIndex({ "priority": 1 });
db.todos.createIndex({ "tags": 1 });

// Insert sample data
db.todos.insertMany([
  {
    title: "Welcome to Todo App",
    description: "This is your first todo item. You can edit or delete it.",
    completed: false,
    priority: "high",
    tags: ["welcome", "sample"],
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    title: "Set up your development environment",
    description: "Configure your local development environment with Docker",
    completed: true,
    priority: "medium",
    tags: ["setup", "development"],
    createdAt: new Date(Date.now() - 86400000), // 1 day ago
    updatedAt: new Date(Date.now() - 86400000)
  },
  {
    title: "Deploy to production",
    description: "Set up CI/CD pipeline and deploy to AWS EC2",
    completed: false,
    priority: "high",
    dueDate: new Date(Date.now() + 7 * 86400000), // 7 days from now
    tags: ["deployment", "aws", "production"],
    createdAt: new Date(),
    updatedAt: new Date()
  }
]);

print('Database initialized with sample data');