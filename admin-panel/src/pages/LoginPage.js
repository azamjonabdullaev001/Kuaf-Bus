import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { authAPI } from '../services/api';
import './LoginPage.css';

function LoginPage() {
  const [universityId, setUniversityId] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const response = await authAPI.login(universityId, password);
      const { token, user_type } = response.data;

      if (user_type !== 'admin') {
        setError('Доступ разрешен только администраторам');
        setLoading(false);
        return;
      }

      localStorage.setItem('token', token);
      localStorage.setItem('userType', user_type);
      navigate('/dashboard');
    } catch (err) {
      setError('Неверный ID или пароль');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <h1>Административная панель</h1>
        <p className="subtitle">Система отслеживания университетских автобусов</p>

        {error && <div className="error-message">{error}</div>}

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Университетский ID</label>
            <input
              type="text"
              value={universityId}
              onChange={(e) => setUniversityId(e.target.value)}
              required
              placeholder="Введите ваш ID"
            />
          </div>

          <div className="form-group">
            <label>Пароль</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              placeholder="Введите пароль"
            />
          </div>

          <button type="submit" disabled={loading} className="btn-primary">
            {loading ? 'Вход...' : 'Войти'}
          </button>
        </form>
      </div>
    </div>
  );
}

export default LoginPage;
