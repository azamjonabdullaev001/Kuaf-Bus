import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { authAPI } from '../services/api';
import { getTranslation as t } from '../translations/translations';
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
        setError(t('accessDenied'));
        setLoading(false);
        return;
      }

      localStorage.setItem('token', token);
      localStorage.setItem('userType', user_type);
      navigate('/dashboard');
    } catch (err) {
      setError(t('invalidCredentials'));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <h1>{t('adminPanel')}</h1>
        <p className="subtitle">{t('busTrackingSystem')}</p>

        {error && <div className="error-message">{error}</div>}

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>{t('universityId')}</label>
            <input
              type="text"
              value={universityId}
              onChange={(e) => setUniversityId(e.target.value)}
              required
              placeholder={t('enterYourId')}
            />
          </div>

          <div className="form-group">
            <label>{t('password')}</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              placeholder={t('enterPassword')}
            />
          </div>

          <button type="submit" disabled={loading} className="btn-primary">
            {loading ? t('loggingIn') : t('login')}
          </button>
        </form>
      </div>
    </div>
  );
}

export default LoginPage;
