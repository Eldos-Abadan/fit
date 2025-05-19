import axios from 'axios';

export const LoginService = async (data) => {
  // URL соңында слэш бар екенін тексеріңіз: /api/login/
  return axios.post('http://localhost:8000/api/login/', data, {
    headers: {
      'Content-Type': 'application/json',
    },
  });
};
