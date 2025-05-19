import {
    Alert,
    Box,
    Button,
    Card,
    CardContent, Chip,
    Divider,
    Grid,
    Stack,
    Table, TableBody, TableCell, TableContainer,
    TableHead,
    TableRow,
    Typography
} from "@mui/material";
import useSWR from "swr";
import {GetAnnouncementsByQuery} from "../service/announcement";
import {
    BadgeRounded,
    DescriptionRounded,
    EventAvailableRounded,
    OutboundRounded
} from "@mui/icons-material";
import DashboardWidget from "../component-pages/dashboard/DashboardWidget";
import DashboardRecentActivity from "../component-pages/dashboard/DashboardRecentActivity";
import {GetUsersByQuery} from "../service/user";
import {useEffect, useState} from "react";
import {CreateAttendance, GetAttendancesByQuery, UpdateAttendance} from "../service/attendance";
import {GetProjectsByQuery} from "../service/project";
import {GetExpensesByQuery} from "../service/expense";
import DashboardRevenueStats from "../component-pages/dashboard/DashboardRevenueStats";
import DashboardMonthlyCustomers from "../component-pages/dashboard/MonthlyCustomers";
import {DefaultSwrOptions, Role} from "../constants/constants";
import {GetNotificationsByQuery} from "../service/notification";
import {BasicSort} from "../constants/sort";
import {useSelector} from "react-redux";
import dayjs from "dayjs";
import moment from "moment";
import {GetTasksByQuery} from "../service/task";

export default function Dashboard() {
    const { role, profile } = useSelector(state => state.profile);

    const [userAttendance, setUserAttendance] = useState(null);

    const [widgets] = useState([
        { title: 'All Employee', content: 0, color: 'primary', icon: BadgeRounded },
        { title: 'Today Attendance', content: 0, color: 'secondary', icon: EventAvailableRounded },
        { title: 'Active Project', content: 0, color: 'tertiary', icon: DescriptionRounded },
        { title: 'Monthly Expense', content: '$0', color: 'info', icon: OutboundRounded }
    ]);

    const { data: resAnnouncement} = useSWR('/api/announcement',
        () => GetAnnouncementsByQuery({active: true}), DefaultSwrOptions);
    const { data: resAllEmployee} = useSWR('/api/employee',
        () => GetUsersByQuery(), DefaultSwrOptions);
    const { data: resTodayAttendance, isLoading: loadingAttendance} = useSWR('/api/attendance',
        () => GetAttendancesByQuery({ today: true }), DefaultSwrOptions);
    const { data: resActiveProject} = useSWR('/api/project',
        () => GetProjectsByQuery({ status: true }), DefaultSwrOptions);
    const { data: resExpense} = useSWR('/api/expense/dashboard',
        () => GetExpensesByQuery({dashboard: true}), DefaultSwrOptions);
    const { data: resRecent} = useSWR('/api/notification',
        () => GetNotificationsByQuery({sort: BasicSort.newest.value, limit: 12}), DefaultSwrOptions);
    const { data: resTask} = useSWR('/api/task',
        () => GetTasksByQuery({sort: BasicSort.newest.value, limit: 12}), DefaultSwrOptions);

    useEffect(() => {
        widgets[0].content = resAllEmployee?.data?.data?.length;
        widgets[1].content = resTodayAttendance?.data?.data?.length;
        widgets[2].content = resActiveProject?.data?.data?.length ?? 0;
        widgets[3].content = `$${resExpense?.data?.data?.month ?? 0}`;

        const attendance = resTodayAttendance?.data?.data?.find(e => e.userId === profile?.id);
        if (attendance) {
            setUserAttendance(attendance);
        }
    }, [
        widgets,
        profile,
        resAllEmployee?.data?.data,
        resTodayAttendance?.data?.data,
        resActiveProject?.data?.data,
        resExpense?.data?.data,
    ]);

    const checkIn = () => {
        return CreateAttendance({
            userId: profile?.id,
            checkIn: dayjs().format()
        }).then((res) => {
            setUserAttendance(res.data?.data);
        });
    }

    const checkOut = () => {
        const attendance = resTodayAttendance?.data?.data?.find(e => e.userId === profile?.id);
        if (attendance) {
            return UpdateAttendance(attendance?.id, {...attendance, checkOut: dayjs().format()})
        }
    }

    const updateAttendance = () => {
        if (userAttendance) {
            checkOut();
        } else {
            checkIn();
        }
    }

    return (
        <>
            {resAnnouncement?.data?.data?.length > 0 && (
                <>
                    <Typography variant="h4" fontWeight={600} marginBottom={2}>Announcement</Typography>
                    <Grid container spacing={3}>
                        {resAnnouncement?.data?.data?.map((e, i) => (
                            <Grid item xs={12} md={6} lg={6} key={i}>
                                <Card>
                                    <CardContent>
                                        <Typography fontWeight={700}>{e.title}</Typography>
                                        <Typography>{e.content}</Typography>
                                    </CardContent>
                                </Card>
                            </Grid>
                        ))}
                    </Grid>
                    <Divider sx={{ marginY: 4 }}/>
                </>
            )}
            {role === Role.admin.value && (
                <Grid container spacing={3}>
                    <Grid item xs={12} sm={12} lg={8}>
                        <Grid container spacing={3}>
                            {widgets.map((e, i) => (
                                <Grid item xs={12} sm={12} md={6} lg={3}>
                                    <DashboardWidget
                                        title={e.title}
                                        icon={e.icon}
                                        color={e.color}
                                        content={e.content}/>
                                </Grid>
                            ))}
                            <Grid item xs={12} sm={12} lg={12}>
                                <DashboardRevenueStats/>
                            </Grid>
                            <Grid item xs={12} sm={12} lg={12}>
                                <DashboardMonthlyCustomers data={resExpense?.data?.data?.annual}/>
                            </Grid>
                        </Grid>
                    </Grid>
                    <Grid item xs={12} sm={12} lg={4}>
                        <Box height={20}/>
                        <DashboardRecentActivity data={resRecent?.data?.data ?? []}/>
                    </Grid>
                </Grid>
            )}
            {role === Role.employee.value && !loadingAttendance && (
                <Grid container spacing={3}>
                    <Grid item xs={12} md={12} lg={12}>
                        <Card>
                            <CardContent>
                                <Stack direction="row" justifyContent="space-between" alignItems="center">
                                    <Box>
                                        <Typography variant="h4">Today</Typography>
                                        <Typography sx={{marginTop: 1, fontStyle: 'italic'}} variant="caption">
                                            {moment().format('DD MMM YYYY hh:mm:ss')}
                                        </Typography>
                                    </Box>
                                    {userAttendance?.checkOut ? (
                                        <Alert severity="success">
                                            Done Work For Today
                                        </Alert>
                                    ) : (
                                        <Button
                                            color={userAttendance ? 'tertiary' : 'primary'}
                                            variant="contained"
                                            onClick={updateAttendance}>
                                            {userAttendance ? 'Check Out' : 'Check In'}
                                        </Button>
                                    )}
                                </Stack>
                            </CardContent>
                        </Card>
                    </Grid>
                    <Grid item xs={12} md={12} lg={12}>
                        <Card>
                            <CardContent>
                                <TableContainer>
                                    <Table sx={{ whiteSpace: 'nowrap' }}>
                                        <TableHead>
                                            <TableRow>
                                                <TableCell>Task Name</TableCell>
                                                <TableCell>Proejct</TableCell>
                                                <TableCell>Progress</TableCell>
                                                <TableCell>Status</TableCell>
                                            </TableRow>
                                        </TableHead>
                                        <TableBody>
                                            {resTask?.data?.data?.length > 0 ? resTask?.data?.data?.map((row, i) => (
                                                <TableRow key={i}>
                                                    <TableCell>{row?.title}</TableCell>
                                                    <TableCell>{row?.project?.name ?? '-'}</TableCell>
                                                    <TableCell>{row?.progress}%</TableCell>
                                                    <TableCell>
                                                        <Chip
                                                            color={row?.status ? 'success' : 'primary'}
                                                            label={row?.status ? 'Active' : 'Completed'}
                                                            size="small"/>
                                                    </TableCell>
                                                </TableRow>
                                            )) : (
                                                <TableRow>
                                                    <TableCell colSpan={7} align="center">No Data</TableCell>
                                                </TableRow>
                                            )}
                                        </TableBody>
                                    </Table>
                                </TableContainer>
                            </CardContent>
                        </Card>
                    </Grid>
                </Grid>
            )}
        </>
    )
}
