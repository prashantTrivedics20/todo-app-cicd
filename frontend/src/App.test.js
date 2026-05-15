import { render, screen } from '@testing-library/react';
import App from './App';

// Mock react-query
jest.mock('react-query', () => ({
  QueryClient: jest.fn(() => ({})),
  QueryClientProvider: ({ children }) => children,
  useQuery: () => ({
    data: { todos: [] },
    isLoading: false,
    error: null
  }),
  useMutation: () => ({
    mutate: jest.fn(),
    isLoading: false
  })
}));

test('renders todo app header', () => {
  render(<App />);
  const headerElement = screen.getByText(/Todo App/i);
  expect(headerElement).toBeInTheDocument();
});

test('renders my todos section', () => {
  render(<App />);
  const todosElement = screen.getByText(/My Todos/i);
  expect(todosElement).toBeInTheDocument();
});