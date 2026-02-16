import axios from 'axios';

// Check if we're in browser environment and have env-config
const getApiUrl = () => {
  // Try to get from window.ENV (injected in production)
  if (typeof window !== 'undefined' && window.ENV && window.ENV.API_URL && window.ENV.API_URL !== '__API_URL__') {
    return window.ENV.API_URL;
  }
  // Try React environment variable
  if (process.env.REACT_APP_API_URL) {
    return process.env.REACT_APP_API_URL;
  }
  // Default to localhost for development
  return 'http://localhost:8080/api';
};

const API_URL = getApiUrl();

const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const authAPI = {
  login: (universityId, password) =>
    apiClient.post('/auth/login', { university_id: universityId, password }),
};

export const adminAPI = {
  createStudent: (data) =>
    apiClient.post('/admin/students', data),
  
  getAllStudents: () =>
    apiClient.get('/admin/students'),
  
  createDriver: (data) =>
    apiClient.post('/admin/drivers', data),
  
  getAllDrivers: () =>
    apiClient.get('/admin/drivers'),
  
  importStudents: (data) =>
    apiClient.post('/admin/students/import', { users: data }),
  
  importDrivers: (data) =>
    apiClient.post('/admin/drivers/import', { users: data }),
  
  searchUsers: (query) =>
    apiClient.get('/admin/users/search', { params: { q: query } }),
  
  deleteUser: (userId) =>
    apiClient.delete('/admin/users/delete', { data: { user_id: userId } }),
  
  deleteAllUsers: (confirmation) =>
    apiClient.delete('/admin/users/delete-all', { data: { confirmation } }),
};

export default apiClient;
