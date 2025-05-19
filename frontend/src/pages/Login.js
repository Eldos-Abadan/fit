import React, { useState } from 'react';
import {
  Alert,
  Box,
  Button,
  Card,
  CardContent,
  FormLabel,
  IconButton,
  InputAdornment,
  Stack,
  TextField,
} from "@mui/material";
import { Link, useNavigate } from "react-router-dom";
import { useFormik } from "formik";
import * as Yup from "yup";
import { VisibilityOffRounded, VisibilityRounded } from "@mui/icons-material";
import { LoginService } from "../service/auth";
import { SetItem } from "../utils/storage";
import { StorageKey } from "../constants/constants";

export default function Login() {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [loadingSubmit, setLoadingSubmit] = useState(false);
  const [error, setError] = useState(null);

  const formik = useFormik({
    initialValues: { email: '', password: '' },
    validationSchema: Yup.object().shape({
      email: Yup.string().email('Invalid email').required('Required'),
      password: Yup.string().required("Please enter a password"),
    }),
    validateOnChange: false,
    validateOnBlur: false,
    onSubmit: values => handleSubmit(values),
  });

  const handleSubmit = async (values) => {
    setLoadingSubmit(true);
    try {
      // Жіберілген сұраныста URL соңында слэш болуына назар аударыңыз: /api/login/
      const res = await LoginService(values);
      if (res.status === 200) {
        // Жауаптың құрылымы: { data: { token: "...", user: { id, email, full_name, role } } }
        const { id, email, full_name, role, token } = res.data.data;
        await SetItem(StorageKey.TOKEN, token);
        await SetItem(StorageKey.USER, JSON.stringify({ id, email, full_name, role }));
        navigate('/app');
      } else {
        setError(res.data);
      }
    } catch (err) {
      if (err.response && err.response.data) {
        setError(err.response.data.detail || 'Something went wrong!');
      }
    }
    setLoadingSubmit(false);
  };

  return (
    <Box>
      <Card sx={{
        width: { xs: '90%', md: '60%', lg: '30%', xl: '25%' },
        margin: 'auto',
        position: 'relative',
        zIndex: 1,
      }}>
        <CardContent>
          <form onSubmit={formik.handleSubmit}>
            <Stack justifyContent="center" alignItems="center" spacing={3} sx={{ minHeight: '100%' }}>
              <Link to="/">
                <img src="/images/logo/logo.svg" alt="logo" style={{ width: 200, height: 80 }} />
              </Link>
              {error && (
                <Alert severity="error">{error}</Alert>
              )}
              <Box sx={{ width: '100%' }}>
                <FormLabel>Email Address</FormLabel>
                <TextField
                  fullWidth
                  name="email"
                  onChange={formik.handleChange}
                  value={formik.values.email}
                  error={Boolean(formik.errors.email)}
                  helperText={formik.errors.email}
                  type="email"
                />
              </Box>
              <Box sx={{ width: '100%' }}>
                <FormLabel>Password</FormLabel>
                <TextField
                  fullWidth
                  name="password"
                  onChange={formik.handleChange}
                  value={formik.values.password}
                  error={Boolean(formik.errors.password)}
                  helperText={formik.errors.password}
                  type={showPassword ? 'text' : 'password'}
                  InputProps={{
                    endAdornment: (
                      <InputAdornment position="end">
                        <IconButton onClick={() => setShowPassword(!showPassword)}>
                          {showPassword ? <VisibilityRounded fontSize="small" /> : <VisibilityOffRounded fontSize="small" />}
                        </IconButton>
                      </InputAdornment>
                    ),
                  }}
                />
              </Box>
              <Button
                fullWidth
                disableElevation
                disabled={loadingSubmit}
                color="primary"
                variant="contained"
                type="submit"
              >
                Login
              </Button>
            </Stack>
          </form>
        </CardContent>
      </Card>
    </Box>
  );
}
