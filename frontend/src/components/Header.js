import React from 'react';

const Header = () => {
  const headerStyle = {
    background: 'linear-gradient(135deg, #4ade80 0%, #22c55e 100%)',
    color: 'white',
    padding: '1rem 2rem',
    boxShadow: '0 2px 10px rgba(0, 0, 0, 0.1)'
  };

  return (
    <header className="header" style={headerStyle}>
      <h1>Todo App</h1>
      <p>Manage your tasks efficiently with our modern todo application</p>
    </header>
  );
};

export default Header;