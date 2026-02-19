import React, { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { adminAPI } from '../services/api';
import * as XLSX from 'xlsx';
import './DashboardPage.css';

function DashboardPage() {
  const [activeTab, setActiveTab] = useState('students');
  const [students, setStudents] = useState([]);
  const [drivers, setDrivers] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [showImportModal, setShowImportModal] = useState(false);
  const [showMappingModal, setShowMappingModal] = useState(false);
  const [showDeleteAllModal, setShowDeleteAllModal] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [isSearching, setIsSearching] = useState(false);
  const [isImporting, setIsImporting] = useState(false);
  const [deleteAllConfirmation, setDeleteAllConfirmation] = useState('');
  const [importData, setImportData] = useState([]);
  const [rawFileData, setRawFileData] = useState([]);
  const [columnMapping, setColumnMapping] = useState({
    university_id: '',
    first_name: '',
    last_name: '',
    middle_name: ''
  });
  const [availableColumns, setAvailableColumns] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage] = useState(50);
  const [formData, setFormData] = useState({
    university_id: '',
    first_name: '',
    last_name: '',
    middle_name: '',
  });
  const fileInputRef = useRef(null);
  const navigate = useNavigate();

  useEffect(() => {
    // Сброс поиска при переключении вкладок
    setIsSearching(false);
    setSearchQuery('');
    setSearchResults([]);
    loadData();
  }, [activeTab]);

  const loadData = async () => {
    try {
      if (activeTab === 'students') {
        const response = await adminAPI.getAllStudents();
        console.log(`Loaded ${response.data?.length || 0} students from backend`);
        setStudents(response.data || []);
      } else {
        const response = await adminAPI.getAllDrivers();
        console.log(`Loaded ${response.data?.length || 0} drivers from backend`);
        setDrivers(response.data || []);
      }
    } catch (error) {
      console.error('Error loading data:', error);
      alert('Ошибка при загрузке данных: ' + (error.response?.data || error.message));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (activeTab === 'students') {
        await adminAPI.createStudent(formData);
      } else {
        await adminAPI.createDriver(formData);
      }
      
      alert(`${activeTab === 'students' ? 'Студент' : 'Водитель'} успешно создан!\nID: ${formData.university_id}\n\nДля входа пользователь должен использовать только свой ID (пароль не требуется)`);
      
      setShowModal(false);
      setFormData({
        university_id: '',
        first_name: '',
        last_name: '',
        middle_name: '',
      });
      
      // Сброс состояния поиска
      setIsSearching(false);
      setSearchQuery('');
      setSearchResults([]);
      
      // Загрузка обновленных данных
      await loadData();
    } catch (error) {
      alert('Ошибка при создании пользователя: ' + (error.response?.data || error.message));
    }
  };

  const handleLogout = () => {
    localStorage.clear();
    navigate('/');
  };

  const handleFileUpload = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const fileExtension = file.name.split('.').pop().toLowerCase();
    const reader = new FileReader();

    reader.onload = (event) => {
      try {
        let data = [];

        if (fileExtension === 'xlsx' || fileExtension === 'xls') {
          // Excel file
          const workbook = XLSX.read(event.target.result, { type: 'binary' });
          const sheetName = workbook.SheetNames[0];
          const worksheet = workbook.Sheets[sheetName];
          data = XLSX.utils.sheet_to_json(worksheet);
        } else if (fileExtension === 'json') {
          // JSON file
          data = JSON.parse(event.target.result);
        } else if (fileExtension === 'txt' || fileExtension === 'csv') {
          // TXT/CSV file (tab or comma separated)
          const lines = event.target.result.split('\n');
          const headers = lines[0].split(/[\t,]/).map(h => h.trim());
          
          data = lines.slice(1).filter(line => line.trim()).map(line => {
            const values = line.split(/[\t,]/).map(v => v.trim());
            const obj = {};
            headers.forEach((header, index) => {
              obj[header] = values[index] || '';
            });
            return obj;
          });
        }

        if (data.length === 0) {
          alert('Файл пустой или неправильный формат');
          return;
        }

        // Get available columns from first row
        const columns = Object.keys(data[0]);
        setAvailableColumns(columns);
        setRawFileData(data);

        // Try to auto-map columns
        const autoMapping = {
          university_id: '',
          first_name: '',
          last_name: '',
          middle_name: ''
        };

        // Auto-detect columns
        columns.forEach(col => {
          const lowerCol = col.toLowerCase();
          if (lowerCol.includes('university') || lowerCol.includes('университет') || lowerCol === 'id' || lowerCol === 'university_id') {
            autoMapping.university_id = col;
          } else if (lowerCol.includes('first') || lowerCol.includes('имя') || lowerCol === 'name' || lowerCol === 'first_name') {
            autoMapping.first_name = col;
          } else if (lowerCol.includes('last') || lowerCol.includes('фамил') || lowerCol === 'surname' || lowerCol === 'last_name') {
            autoMapping.last_name = col;
          } else if (lowerCol.includes('middle') || lowerCol.includes('отчест') || lowerCol === 'patronymic' || lowerCol === 'middle_name') {
            autoMapping.middle_name = col;
          }
        });

        setColumnMapping(autoMapping);
        setShowMappingModal(true);
      } catch (error) {
        alert('Ошибка при чтении файла: ' + error.message);
      }
    };

    if (fileExtension === 'xlsx' || fileExtension === 'xls') {
      reader.readAsBinaryString(file);
    } else {
      reader.readAsText(file);
    }

    // Reset file input
    e.target.value = '';
  };

  const applyMapping = () => {
    // Validate that required fields are mapped
    if (!columnMapping.university_id || !columnMapping.first_name || !columnMapping.last_name) {
      alert('Пожалуйста, укажите соответствие для обязательных полей:\n- Университетский ID\n- Имя\n- Фамилия');
      return;
    }

    // Apply mapping to data and filter out invalid rows
    const mappedData = rawFileData
      .map((row, index) => ({
        university_id: (row[columnMapping.university_id] || '').toString().trim(),
        first_name: (row[columnMapping.first_name] || '').toString().trim(),
        last_name: (row[columnMapping.last_name] || '').toString().trim(),
        middle_name: (row[columnMapping.middle_name] || '').toString().trim(),
      }))
      .filter((row, index) => {
        // Skip rows with empty required fields
        if (!row.university_id || !row.first_name || !row.last_name) {
          console.warn(`Пропущена строка ${index + 1}: пустые обязательные поля`);
          return false;
        }
        return true;
      });

    if (mappedData.length === 0) {
      alert('Нет валидных строк для импорта.\nУбедитесь, что файл содержит данные с заполненными полями:\n- Университетский ID\n- Имя\n- Фамилия');
      return;
    }

    console.log('Mapped data:', mappedData);
    setImportData(mappedData);
    setShowMappingModal(false);
    setShowImportModal(true);
  };

  const handleImport = async () => {
    try {
      if (!importData || importData.length === 0) {
        alert('Нет данных для импорта');
        return;
      }

      console.log('Sending import request:', { users: importData });
      
      // Показываем индикатор загрузки
      setIsImporting(true);

      const endpoint = activeTab === 'students' 
        ? adminAPI.importStudents 
        : adminAPI.importDrivers;
      
      const startTime = Date.now();
      const response = await endpoint(importData);
      const duration = ((Date.now() - startTime) / 1000).toFixed(2);
      
      const { success, failed, total, errors } = response.data;
      
      let message = `Импорт завершен за ${duration} сек:\n\n`;
      message += `✓ Успешно: ${success} из ${total}\n`;
      if (failed > 0) {
        message += `✗ Ошибок: ${failed}\n\n`;
        if (errors && errors.length > 0) {
          message += `Детали ошибок:\n`;
          errors.slice(0, 5).forEach(err => {
            message += `• ${err}\n`;
          });
          if (errors.length > 5) {
            message += `... и еще ${errors.length - 5} ошибок\n`;
          }
        }
      }
      
      alert(message);
      setShowImportModal(false);
      setImportData([]);
      setRawFileData([]);
      
      // Сброс состояния поиска
      setIsSearching(false);
      setSearchQuery('');
      setSearchResults([]);
      
      // Загрузка обновленных данных
      await loadData();
    } catch (error) {
      alert('Ошибка при импорте: ' + (error.response?.data?.message || error.message));
    } finally {
      setIsImporting(false);
    }
  };

  const downloadTemplate = () => {
    const template = [
      {
        university_id: '12345678',
        first_name: 'Иван',
        last_name: 'Иванов',
        middle_name: 'Иванович'
      }
    ];

    const ws = XLSX.utils.json_to_sheet(template);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, 'Template');
    XLSX.writeFile(wb, `template_${activeTab}.xlsx`);
  };

  const handleSearch = async (query) => {
    setSearchQuery(query);
    
    if (!query || query.trim().length < 2) {
      setIsSearching(false);
      setSearchResults([]);
      setCurrentPage(1);
      return;
    }

    try {
      setIsSearching(true);
      setCurrentPage(1);
      const response = await adminAPI.searchUsers(query);
      setSearchResults(response.data || []);
    } catch (error) {
      console.error('Search error:', error);
      setSearchResults([]);
    }
  };

  const handleDeleteUser = async (userId, userName) => {
    if (!window.confirm(`Вы уверены, что хотите удалить пользователя ${userName}?`)) {
      return;
    }

    try {
      await adminAPI.deleteUser(userId);
      alert('Пользователь успешно удален');
      
      // Если был активен поиск, обновляем результаты поиска
      if (isSearching && searchQuery) {
        await handleSearch(searchQuery);
      }
      
      // Всегда обновляем полный список
      await loadData();
    } catch (error) {
      alert('Ошибка при удалении: ' + (error.response?.data || error.message));
    }
  };

  const handleDeleteAll = async () => {
    if (deleteAllConfirmation !== 'DELETE ALL USERS') {
      alert('Пожалуйста, введите точный текст подтверждения: DELETE ALL USERS');
      return;
    }

    try {
      const response = await adminAPI.deleteAllUsers(deleteAllConfirmation);
      alert(response.data.message);
      
      // Закрываем модальное окно и сбрасываем подтверждение
      setShowDeleteAllModal(false);
      setDeleteAllConfirmation('');
      
      // Полный сброс состояния поиска
      setIsSearching(false);
      setSearchQuery('');
      setSearchResults([]);
      
      // Загружаем обновленные данные
      await loadData();
    } catch (error) {
      alert('Ошибка при удалении: ' + (error.response?.data || error.message));
    }
  };

  return (
    <div className="dashboard">
      <nav className="navbar">
        <h1>Панель администратора</h1>
        <button onClick={handleLogout} className="btn-logout">
          Выйти
        </button>
      </nav>

      <div className="container">
        <div className="tabs">
          <button
            className={activeTab === 'students' ? 'tab active' : 'tab'}
            onClick={() => {
              setActiveTab('students');
              setCurrentPage(1);
              setSearchQuery('');
              setIsSearching(false);
            }}
          >
            Студенты
          </button>
          <button
            className={activeTab === 'drivers' ? 'tab active' : 'tab'}
            onClick={() => {
              setActiveTab('drivers');
              setCurrentPage(1);
              setSearchQuery('');
              setIsSearching(false);
            }}
          >
            Водители
          </button>
        </div>

        <div className="content">
          <div className="header">
            <h2>{activeTab === 'students' ? 'Список студентов' : 'Список водителей'}</h2>
            <div className="header-actions">
              <input
                type="text"
                placeholder="Поиск по имени, фамилии или ID..."
                value={searchQuery}
                onChange={(e) => handleSearch(e.target.value)}
                className="search-input"
                style={{ padding: '10px', borderRadius: '8px', border: '1px solid #ddd', marginRight: '10px' }}
              />
              <button onClick={() => setShowModal(true)} className="btn-add">
                + Добавить {activeTab === 'students' ? 'студента' : 'водителя'}
              </button>
              <button onClick={() => fileInputRef.current.click()} className="btn-import">
                📁 Импорт
              </button>
              <button 
                onClick={() => setShowDeleteAllModal(true)} 
                className="btn-delete-all"
                style={{ backgroundColor: '#dc3545', color: 'white' }}
              >
                🗑️ Удалить всех
              </button>
              <input
                ref={fileInputRef}
                type="file"
                accept=".xlsx,.xls,.json,.txt,.csv"
                onChange={handleFileUpload}
                style={{ display: 'none' }}
              />
            </div>
          </div>

          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Университетский ID</th>
                  <th>Имя</th>
                  <th>Фамилия</th>
                  <th>Отчество</th>
                  <th>Тип</th>
                  <th>Действия</th>
                </tr>
              </thead>
              <tbody>
                {(() => {
                  // Определяем какой список показывать
                  let displayList = [];
                  if (isSearching && searchQuery) {
                    displayList = searchResults || [];
                  } else {
                    displayList = (activeTab === 'students' ? students : drivers) || [];
                  }

                  // Применяем пагинацию
                  const startIndex = (currentPage - 1) * itemsPerPage;
                  const endIndex = startIndex + itemsPerPage;
                  const paginatedList = displayList.slice(startIndex, endIndex);

                  return paginatedList.map((user) => (
                    <tr key={user.id}>
                      <td>{user.id}</td>
                      <td>{user.university_id}</td>
                      <td>{user.first_name}</td>
                      <td>{user.last_name}</td>
                      <td>{user.middle_name || '-'}</td>
                      <td>{user.user_type === 'student' ? 'Студент' : 'Водитель'}</td>
                      <td>
                        <button 
                          onClick={() => handleDeleteUser(user.id, `${user.first_name} ${user.last_name}`)}
                          className="btn-delete-user"
                          style={{ backgroundColor: '#dc3545', color: 'white', padding: '5px 10px', borderRadius: '5px', border: 'none', cursor: 'pointer' }}
                        >
                          Удалить
                        </button>
                      </td>
                    </tr>
                  ));
                })()}
              </tbody>
            </table>
            {isSearching && searchResults.length === 0 && searchQuery && (
              <div style={{ textAlign: 'center', padding: '20px', color: '#666' }}>
                Ничего не найдено
              </div>
            )}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px', borderTop: '1px solid #ddd' }}>
              <div style={{ color: '#666' }}>
                {(() => {
                  const displayList = (isSearching && searchQuery) ? searchResults : (activeTab === 'students' ? students : drivers);
                  const total = displayList?.length || 0;
                  const startIndex = (currentPage - 1) * itemsPerPage + 1;
                  const endIndex = Math.min(currentPage * itemsPerPage, total);
                  return total > 0 
                    ? `Показано: ${startIndex}-${endIndex} из ${total} ${activeTab === 'students' ? 'студентов' : 'водителей'}`
                    : `Нет ${activeTab === 'students' ? 'студентов' : 'водителей'}`;
                })()}
              </div>
              <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
                {(() => {
                  const displayList = (isSearching && searchQuery) ? searchResults : (activeTab === 'students' ? students : drivers);
                  const total = displayList?.length || 0;
                  const totalPages = Math.ceil(total / itemsPerPage);
                  
                  if (totalPages <= 1) return null;
                  
                  return (
                    <>
                      <button 
                        onClick={() => setCurrentPage(prev => Math.max(1, prev - 1))}
                        disabled={currentPage === 1}
                        style={{
                          padding: '5px 15px',
                          cursor: currentPage === 1 ? 'not-allowed' : 'pointer',
                          opacity: currentPage === 1 ? 0.5 : 1,
                          borderRadius: '5px',
                          border: '1px solid #ddd',
                          backgroundColor: 'white'
                        }}
                      >
                        ← Назад
                      </button>
                      <span style={{ color: '#666' }}>
                        Страница {currentPage} из {totalPages}
                      </span>
                      <button 
                        onClick={() => setCurrentPage(prev => Math.min(totalPages, prev + 1))}
                        disabled={currentPage === totalPages}
                        style={{
                          padding: '5px 15px',
                          cursor: currentPage === totalPages ? 'not-allowed' : 'pointer',
                          opacity: currentPage === totalPages ? 0.5 : 1,
                          borderRadius: '5px',
                          border: '1px solid #ddd',
                          backgroundColor: 'white'
                        }}
                      >
                        Вперёд →
                      </button>
                    </>
                  );
                })()}
              </div>
            </div>
          </div>
        </div>
      </div>

      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h2>Добавить {activeTab === 'students' ? 'студента' : 'водителя'}</h2>
            <form onSubmit={handleSubmit}>
              <div className="form-group">
                <label>Университетский ID *</label>
                <input
                  type="text"
                  value={formData.university_id}
                  onChange={(e) => setFormData({ ...formData, university_id: e.target.value })}
                  required
                />
              </div>

              <div className="form-group">
                <label>Имя *</label>
                <input
                  type="text"
                  value={formData.first_name}
                  onChange={(e) => setFormData({ ...formData, first_name: e.target.value })}
                  required
                />
              </div>

              <div className="form-group">
                <label>Фамилия *</label>
                <input
                  type="text"
                  value={formData.last_name}
                  onChange={(e) => setFormData({ ...formData, last_name: e.target.value })}
                  required
                />
              </div>

              <div className="form-group">
                <label>Отчество</label>
                <input
                  type="text"
                  value={formData.middle_name}
                  onChange={(e) => setFormData({ ...formData, middle_name: e.target.value })}
                />
              </div>

              <div className="modal-actions">
                <button type="button" onClick={() => setShowModal(false)} className="btn-cancel">
                  Отмена
                </button>
                <button type="submit" className="btn-submit">
                  Создать
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {showMappingModal && (
        <div className="modal-overlay" onClick={() => setShowMappingModal(false)}>
          <div className="modal modal-large" onClick={(e) => e.stopPropagation()}>
            <h2>Настройка соответствия колонок</h2>
            <p className="mapping-description">
              Выберите, какие колонки из вашего файла соответствуют полям в базе данных.
              <br />
              <strong>Обязательные поля:</strong> Университетский ID, Имя, Фамилия
            </p>
            
            <div className="mapping-container">
              <div className="mapping-row">
                <label className="mapping-label required">
                  Университетский ID *
                </label>
                <select 
                  value={columnMapping.university_id}
                  onChange={(e) => setColumnMapping({...columnMapping, university_id: e.target.value})}
                  className="mapping-select"
                >
                  <option value="">-- Выберите колонку --</option>
                  {availableColumns.map(col => (
                    <option key={col} value={col}>{col}</option>
                  ))}
                </select>
                {columnMapping.university_id && (
                  <span className="preview">
                    Пример: {rawFileData[0]?.[columnMapping.university_id]}
                  </span>
                )}
              </div>

              <div className="mapping-row">
                <label className="mapping-label required">
                  Имя *
                </label>
                <select 
                  value={columnMapping.first_name}
                  onChange={(e) => setColumnMapping({...columnMapping, first_name: e.target.value})}
                  className="mapping-select"
                >
                  <option value="">-- Выберите колонку --</option>
                  {availableColumns.map(col => (
                    <option key={col} value={col}>{col}</option>
                  ))}
                </select>
                {columnMapping.first_name && (
                  <span className="preview">
                    Пример: {rawFileData[0]?.[columnMapping.first_name]}
                  </span>
                )}
              </div>

              <div className="mapping-row">
                <label className="mapping-label required">
                  Фамилия *
                </label>
                <select 
                  value={columnMapping.last_name}
                  onChange={(e) => setColumnMapping({...columnMapping, last_name: e.target.value})}
                  className="mapping-select"
                >
                  <option value="">-- Выберите колонку --</option>
                  {availableColumns.map(col => (
                    <option key={col} value={col}>{col}</option>
                  ))}
                </select>
                {columnMapping.last_name && (
                  <span className="preview">
                    Пример: {rawFileData[0]?.[columnMapping.last_name]}
                  </span>
                )}
              </div>

              <div className="mapping-row">
                <label className="mapping-label">
                  Отчество
                </label>
                <select 
                  value={columnMapping.middle_name}
                  onChange={(e) => setColumnMapping({...columnMapping, middle_name: e.target.value})}
                  className="mapping-select"
                >
                  <option value="">-- Выберите колонку (необязательно) --</option>
                  {availableColumns.map(col => (
                    <option key={col} value={col}>{col}</option>
                  ))}
                </select>
                {columnMapping.middle_name && (
                  <span className="preview">
                    Пример: {rawFileData[0]?.[columnMapping.middle_name]}
                  </span>
                )}
              </div>
            </div>

            <div className="file-preview">
              <strong>Найдено записей в файле:</strong> {rawFileData.length}
            </div>

            <div className="modal-actions">
              <button type="button" onClick={() => setShowMappingModal(false)} className="btn-cancel">
                Отмена
              </button>
              <button type="button" onClick={applyMapping} className="btn-submit">
                Далее →
              </button>
            </div>
          </div>
        </div>
      )}

      {showImportModal && (
        <div className="modal-overlay" onClick={() => setShowImportModal(false)}>
          <div className="modal modal-large" onClick={(e) => e.stopPropagation()}>
            <h2>Предварительный просмотр импорта</h2>
            <p>Найдено записей: {importData.length}</p>
            
            <div className="import-preview">
              <table>
                <thead>
                  <tr>
                    <th>Университетский ID</th>
                    <th>Имя</th>
                    <th>Фамилия</th>
                    <th>Отчество</th>
                  </tr>
                </thead>
                <tbody>
                  {importData.slice(0, 10).map((user, index) => (
                    <tr key={index}>
                      <td>{user.university_id}</td>
                      <td>{user.first_name}</td>
                      <td>{user.last_name}</td>
                      <td>{user.middle_name || '-'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
              {importData.length > 10 && (
                <p className="preview-note">Показаны первые 10 записей из {importData.length}</p>
              )}
            </div>

            <div className="modal-actions">
              <button 
                type="button" 
                onClick={() => setShowImportModal(false)} 
                className="btn-cancel"
                disabled={isImporting}
              >
                Отмена
              </button>
              <button 
                type="button" 
                onClick={handleImport} 
                className="btn-submit"
                disabled={isImporting}
                style={{ 
                  opacity: isImporting ? 0.7 : 1,
                  cursor: isImporting ? 'wait' : 'pointer'
                }}
              >
                {isImporting 
                  ? `⏳ Импортируется... (${importData.length} записей)`
                  : `Импортировать ${importData.length} записей`
                }
              </button>
            </div>
          </div>
        </div>
      )}

      {showDeleteAllModal && (
        <div className="modal-overlay" onClick={() => setShowDeleteAllModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h2 style={{ color: '#dc3545' }}>⚠️ Удаление всех пользователей</h2>
            <p style={{ marginBottom: '20px' }}>
              Это действие удалит <strong>всех студентов и водителей</strong> из базы данных.<br/>
              Администраторы НЕ будут удалены.<br/><br/>
              <strong>Это действие необратимо!</strong>
            </p>
            
            <div className="form-group">
              <label style={{ fontWeight: 'bold', marginBottom: '10px', display: 'block' }}>
                Для подтверждения введите точный текст:
              </label>
              <div style={{ 
                backgroundColor: '#f8f9fa', 
                padding: '10px', 
                borderRadius: '5px', 
                marginBottom: '15px',
                fontFamily: 'monospace',
                fontSize: '14px'
              }}>
                DELETE ALL USERS
              </div>
              <input
                type="text"
                value={deleteAllConfirmation}
                onChange={(e) => setDeleteAllConfirmation(e.target.value)}
                placeholder="Введите текст подтверждения"
                style={{ 
                  width: '100%', 
                  padding: '10px', 
                  borderRadius: '5px',
                  border: '1px solid #ddd',
                  fontFamily: 'monospace'
                }}
              />
            </div>

            <div className="modal-actions" style={{ marginTop: '20px' }}>
              <button 
                type="button" 
                onClick={() => {
                  setShowDeleteAllModal(false);
                  setDeleteAllConfirmation('');
                }} 
                className="btn-cancel"
              >
                Отмена
              </button>
              <button 
                type="button" 
                onClick={handleDeleteAll} 
                className="btn-submit"
                style={{ backgroundColor: '#dc3545' }}
                disabled={deleteAllConfirmation !== 'DELETE ALL USERS'}
              >
                Удалить всех пользователей
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default DashboardPage;
