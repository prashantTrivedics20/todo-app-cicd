const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../server');
const Todo = require('../models/Todo');

// Test database
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/todoapp_test';

describe('Todo API', () => {
  beforeAll(async () => {
    await mongoose.connect(MONGODB_URI);
  });

  beforeEach(async () => {
    await Todo.deleteMany({});
  });

  afterAll(async () => {
    await mongoose.connection.close();
  });

  describe('GET /api/todos', () => {
    it('should return empty array when no todos exist', async () => {
      const response = await request(app)
        .get('/api/todos')
        .expect(200);

      expect(response.body.todos).toEqual([]);
      expect(response.body.total).toBe(0);
    });

    it('should return todos when they exist', async () => {
      const todo = new Todo({
        title: 'Test Todo',
        description: 'Test Description',
        priority: 'high'
      });
      await todo.save();

      const response = await request(app)
        .get('/api/todos')
        .expect(200);

      expect(response.body.todos).toHaveLength(1);
      expect(response.body.todos[0].title).toBe('Test Todo');
    });
  });

  describe('POST /api/todos', () => {
    it('should create a new todo', async () => {
      const todoData = {
        title: 'New Todo',
        description: 'New Description',
        priority: 'medium'
      };

      const response = await request(app)
        .post('/api/todos')
        .send(todoData)
        .expect(201);

      expect(response.body.title).toBe(todoData.title);
      expect(response.body.description).toBe(todoData.description);
      expect(response.body.priority).toBe(todoData.priority);
      expect(response.body.completed).toBe(false);
    });

    it('should return 400 for invalid todo data', async () => {
      const response = await request(app)
        .post('/api/todos')
        .send({})
        .expect(400);

      expect(response.body.error).toContain('required');
    });
  });

  describe('PUT /api/todos/:id', () => {
    it('should update an existing todo', async () => {
      const todo = new Todo({
        title: 'Original Title',
        description: 'Original Description'
      });
      await todo.save();

      const updateData = {
        title: 'Updated Title',
        completed: true
      };

      const response = await request(app)
        .put(`/api/todos/${todo._id}`)
        .send(updateData)
        .expect(200);

      expect(response.body.title).toBe(updateData.title);
      expect(response.body.completed).toBe(true);
    });

    it('should return 404 for non-existent todo', async () => {
      const fakeId = new mongoose.Types.ObjectId();
      
      await request(app)
        .put(`/api/todos/${fakeId}`)
        .send({ title: 'Updated' })
        .expect(404);
    });
  });

  describe('DELETE /api/todos/:id', () => {
    it('should delete an existing todo', async () => {
      const todo = new Todo({
        title: 'Todo to Delete',
        description: 'This will be deleted'
      });
      await todo.save();

      await request(app)
        .delete(`/api/todos/${todo._id}`)
        .expect(200);

      const deletedTodo = await Todo.findById(todo._id);
      expect(deletedTodo).toBeNull();
    });
  });

  describe('PATCH /api/todos/:id/toggle', () => {
    it('should toggle todo completion status', async () => {
      const todo = new Todo({
        title: 'Todo to Toggle',
        completed: false
      });
      await todo.save();

      const response = await request(app)
        .patch(`/api/todos/${todo._id}/toggle`)
        .expect(200);

      expect(response.body.completed).toBe(true);
    });
  });

  describe('GET /health', () => {
    it('should return health status', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(response.body.status).toBe('OK');
      expect(response.body.timestamp).toBeDefined();
    });
  });
});