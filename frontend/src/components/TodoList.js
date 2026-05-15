import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from 'react-query';
import toast from 'react-hot-toast';
import { Plus, Edit2, Trash2, Check, X } from 'lucide-react';
import { todoAPI } from '../services/api';
import TodoForm from './TodoForm';
import TodoItem from './TodoItem';

const TodoList = () => {
  const [filter, setFilter] = useState('all');
  const [showForm, setShowForm] = useState(false);
  const [editingTodo, setEditingTodo] = useState(null);
  const queryClient = useQueryClient();

  // Fetch todos
  const { data: todosData, isLoading, error } = useQuery(
    ['todos', filter],
    () => todoAPI.getTodos({ completed: filter === 'all' ? undefined : filter === 'completed' }),
    {
      onError: (error) => {
        toast.error('Failed to fetch todos');
        console.error('Fetch error:', error);
      }
    }
  );

  // Create todo mutation
  const createMutation = useMutation(todoAPI.createTodo, {
    onSuccess: () => {
      queryClient.invalidateQueries(['todos']);
      toast.success('Todo created successfully!');
      setShowForm(false);
    },
    onError: (error) => {
      toast.error('Failed to create todo');
      console.error('Create error:', error);
    }
  });

  // Update todo mutation
  const updateMutation = useMutation(
    ({ id, data }) => todoAPI.updateTodo(id, data),
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['todos']);
        toast.success('Todo updated successfully!');
        setEditingTodo(null);
      },
      onError: (error) => {
        toast.error('Failed to update todo');
        console.error('Update error:', error);
      }
    }
  );

  // Delete todo mutation
  const deleteMutation = useMutation(todoAPI.deleteTodo, {
    onSuccess: () => {
      queryClient.invalidateQueries(['todos']);
      toast.success('Todo deleted successfully!');
    },
    onError: (error) => {
      toast.error('Failed to delete todo');
      console.error('Delete error:', error);
    }
  });

  // Toggle todo completion
  const toggleMutation = useMutation(todoAPI.toggleTodo, {
    onSuccess: () => {
      queryClient.invalidateQueries(['todos']);
    },
    onError: (error) => {
      toast.error('Failed to toggle todo');
      console.error('Toggle error:', error);
    }
  });

  const handleCreateTodo = (todoData) => {
    createMutation.mutate(todoData);
  };

  const handleUpdateTodo = (id, todoData) => {
    updateMutation.mutate({ id, data: todoData });
  };

  const handleDeleteTodo = (id) => {
    if (window.confirm('Are you sure you want to delete this todo?')) {
      deleteMutation.mutate(id);
    }
  };

  const handleToggleTodo = (id) => {
    toggleMutation.mutate(id);
  };

  const handleEditTodo = (todo) => {
    setEditingTodo(todo);
    setShowForm(true);
  };

  const handleCancelEdit = () => {
    setEditingTodo(null);
    setShowForm(false);
  };

  if (isLoading) {
    return (
      <div className="todo-container">
        <div className="loading">
          <p>Loading todos...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="todo-container">
        <div className="loading">
          <p>Error loading todos. Please try again.</p>
        </div>
      </div>
    );
  }

  const todos = todosData?.todos || [];
  const filteredTodos = todos.filter(todo => {
    if (filter === 'all') return true;
    if (filter === 'completed') return todo.completed;
    if (filter === 'pending') return !todo.completed;
    return true;
  });

  return (
    <div className="todo-container">
      <div className="todo-header">
        <h2>My Todos</h2>
        
        {/* Filters */}
        <div className="filters">
          <button
            className={`filter-btn ${filter === 'all' ? 'active' : ''}`}
            onClick={() => setFilter('all')}
          >
            All ({todos.length})
          </button>
          <button
            className={`filter-btn ${filter === 'pending' ? 'active' : ''}`}
            onClick={() => setFilter('pending')}
          >
            Pending ({todos.filter(t => !t.completed).length})
          </button>
          <button
            className={`filter-btn ${filter === 'completed' ? 'active' : ''}`}
            onClick={() => setFilter('completed')}
          >
            Completed ({todos.filter(t => t.completed).length})
          </button>
        </div>

        {/* Add Todo Button */}
        <button
          className="btn btn-primary"
          onClick={() => setShowForm(!showForm)}
          disabled={createMutation.isLoading}
        >
          <Plus size={20} />
          Add New Todo
        </button>

        {/* Todo Form */}
        {showForm && (
          <TodoForm
            todo={editingTodo}
            onSubmit={editingTodo ? 
              (data) => handleUpdateTodo(editingTodo._id, data) : 
              handleCreateTodo
            }
            onCancel={handleCancelEdit}
            isLoading={editingTodo ? updateMutation.isLoading : createMutation.isLoading}
          />
        )}
      </div>

      <div className="todo-list">
        {filteredTodos.length === 0 ? (
          <div className="empty-state">
            <h3>No todos found</h3>
            <p>
              {filter === 'all' 
                ? "Start by adding your first todo!" 
                : `No ${filter} todos at the moment.`
              }
            </p>
          </div>
        ) : (
          filteredTodos.map(todo => (
            <TodoItem
              key={todo._id}
              todo={todo}
              onToggle={() => handleToggleTodo(todo._id)}
              onEdit={() => handleEditTodo(todo)}
              onDelete={() => handleDeleteTodo(todo._id)}
              isToggling={toggleMutation.isLoading}
              isDeleting={deleteMutation.isLoading}
            />
          ))
        )}
      </div>
    </div>
  );
};

export default TodoList;