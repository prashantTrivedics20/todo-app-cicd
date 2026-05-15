import React from 'react';
import { Edit2, Trash2 } from 'lucide-react';
import { format } from 'date-fns';

const TodoItem = ({ todo, onToggle, onEdit, onDelete, isToggling, isDeleting }) => {
  const getPriorityClass = (priority) => {
    switch (priority) {
      case 'high': return 'priority-high';
      case 'medium': return 'priority-medium';
      case 'low': return 'priority-low';
      default: return 'priority-medium';
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return null;
    try {
      return format(new Date(dateString), 'MMM dd, yyyy');
    } catch (error) {
      return null;
    }
  };

  return (
    <div className="todo-item">
      <input
        type="checkbox"
        className="todo-checkbox"
        checked={todo.completed}
        onChange={onToggle}
        disabled={isToggling}
      />
      
      <div className="todo-content">
        <h3 className={`todo-title ${todo.completed ? 'completed' : ''}`}>
          {todo.title}
        </h3>
        
        {todo.description && (
          <p className="todo-description">{todo.description}</p>
        )}
        
        <div className="todo-meta">
          <span className={`priority-badge ${getPriorityClass(todo.priority)}`}>
            {todo.priority}
          </span>
          
          {todo.dueDate && (
            <span className="due-date">
              Due: {formatDate(todo.dueDate)}
            </span>
          )}
          
          {todo.tags && todo.tags.length > 0 && (
            <span className="tags">
              Tags: {todo.tags.join(', ')}
            </span>
          )}
          
          <span className="created-date">
            Created: {formatDate(todo.createdAt)}
          </span>
        </div>
      </div>
      
      <div className="todo-actions">
        <button
          className="btn btn-secondary btn-sm"
          onClick={onEdit}
          disabled={isToggling || isDeleting}
          title="Edit todo"
        >
          <Edit2 size={16} />
        </button>
        
        <button
          className="btn btn-danger btn-sm"
          onClick={onDelete}
          disabled={isToggling || isDeleting}
          title="Delete todo"
        >
          <Trash2 size={16} />
        </button>
      </div>
    </div>
  );
};

export default TodoItem;