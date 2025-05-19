import {useNavigate, useParams} from "react-router-dom";
import {useEffect, useRef, useState} from "react";
import {useFormik} from "formik";
import useSWR from "swr";
import * as Yup from "yup";
import Breadcrumb from "../../components/Breadcrumb";
import {
    Alert,
    Box,
    Button,
    Card,
    CardContent,
    FormLabel,
    Grid,
    MenuItem,
    Select,
    Stack,
} from "@mui/material";
import {CreateAttendance, GetAttendanceById, UpdateAttendance} from "../../service/attendance";
import dayjs from "dayjs";
import {GetUsersByQuery} from "../../service/user";
import CustomDateTimePicker from "../../components/forms/Datepicker/CustomDateTimePicker";
import {useSelector} from "react-redux";
import {Role} from "../../constants/constants";

export default function AttendanceForm() {
    const { id } = useParams();
    const navigate = useNavigate();
    const { role, profile } = useSelector(state => state.profile);

    const { data: resData, isLoading: loading} = useSWR(id ? ['/api/attendance', id] : null,
        () => GetAttendanceById(id));
    const { data: resUser, isLoading: loadingUser} = useSWR('/api/user', () => GetUsersByQuery());

    const [loadingSubmit, setLoadingSubmit] = useState(false);
    const [error, setError] = useState(null);

    const formik = useFormik({
        initialValues: {
            userId: resData?.data?.data?.userId ?? '',
            checkIn: resData?.data?.data?.checkIn ?? null,
            checkOut: resData?.data?.data?.checkOut ?? null,
        },
        validationSchema: Yup.object().shape({
            // userId: Yup.string().required('Required'),
            checkIn: Yup.string().required('Required'),
        }),
        validateOnChange: false,
        validateOnBlur: false,
        onSubmit: values => handleSubmit(values)
    });

    const mounted = useRef(false);
    useEffect(() => {
        if (!mounted.current && resData?.data?.data?._id) {
            formik.setValues(resData?.data?.data);
            mounted.current = true;
        }
    }, [resData?.data?.data]);

    const submit = (params) => {
        delete params._id;
        params.checkIn = dayjs(params.checkIn).format();
        if (params.checkOut) params.checkOut = dayjs(params.checkOut).format();
        if (role === Role.employee.value) params.userId = profile?.id;

        if (id) {
            return UpdateAttendance(id, params);
        }

        return CreateAttendance(params);
    }

    const handleSubmit = async (values) => {
        setLoadingSubmit(true);
        return submit(values).then(res => {
            if (res.status === 200) {
                navigate('/app/attendance');
            } else {
                setError(res.data);
            }
            setLoadingSubmit(false);
        });
    };

    return (
        <>
            <Breadcrumb
                title={`${id ? 'Update' : 'Create'} Attendance`}
                items={[
                    { to: '/app', title: 'Dashboard' },
                    { to: '/app/user', title: 'Attendances' },
                    { title: `${id ? 'Update' : 'Create'} Attendance` },
                ]}/>
            {error && (
                <>
                    <Alert severity="error">{error}</Alert>
                    <Box height={20}/>
                </>
            )}
            <Box sx={{ width: { xs: '100%', lg: '50%' }}}>
                <form onSubmit={formik.handleSubmit}>
                    <Stack spacing={3}>
                        <Card>
                            <CardContent>
                                <Stack spacing={3}>
                                    {role === Role.admin.value && (
                                        <Grid container>
                                            <Grid item xs={12} md={4} lg={3}>
                                                <FormLabel>Employee</FormLabel>
                                            </Grid>
                                            <Grid item xs={12} md={8} lg={9}>
                                                <Select
                                                    fullWidth
                                                    name="userId"
                                                    onChange={formik.handleChange}
                                                    value={formik.values.userId}>
                                                    {resUser?.data?.data?.map((e, i) => (
                                                        <MenuItem key={i} value={e.id}>
                                                            {e.name}
                                                        </MenuItem>
                                                    ))}
                                                </Select>
                                            </Grid>
                                        </Grid>
                                    )}
                                    <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Check In</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <CustomDateTimePicker
                                                error={Boolean(formik.errors.checkIn)}
                                                onChange={(val) => formik.setFieldValue('checkIn', val)}
                                                value={formik.values.checkIn}
                                            />
                                        </Grid>
                                    </Grid>
                                    <Grid container>
                                        <Grid item xs={12} md={4} lg={3}>
                                            <FormLabel>Check Out</FormLabel>
                                        </Grid>
                                        <Grid item xs={12} md={8} lg={9}>
                                            <CustomDateTimePicker
                                                error={Boolean(formik.errors.checkOut)}
                                                onChange={(val) => formik.setFieldValue('checkOut', val)}
                                                value={formik.values.checkOut}/>
                                        </Grid>
                                    </Grid>
                                </Stack>
                            </CardContent>
                        </Card>
                        <Stack direction="row" justifyContent="end">
                            <Button
                                disabled={loadingSubmit}
                                color="primary"
                                variant="contained"
                                type="submit">
                                Submit
                            </Button>
                        </Stack>
                    </Stack>
                </form>
            </Box>
        </>
    )
}