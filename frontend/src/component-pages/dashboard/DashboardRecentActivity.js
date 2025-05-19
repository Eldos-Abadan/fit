import {Box, Card, Chip, Stack, Typography} from "@mui/material";
import moment from "moment";

export default function DashboardRecentActivity(props) {
    const { data } = props;

    return (
        <Box>
            <Typography variant="h5">Recent Activity</Typography>
            <Typography variant="subtitle2" color="textSecondary">
                Latest project and task
            </Typography>
            <Box height={20}/>
            <Stack spacing={2}>
                {data.map((e, i) => (
                    <Card sx={{ padding: '15px 20px' }}>
                        <Stack direction="row" spacing={2} alignItems="center">
                            <Box flex={1}>
                                <Typography variant="subtitle2">{e.title}</Typography>
                                <Typography variant="caption" color="textSecondary">{e.description}</Typography>
                            </Box>
                            <Typography
                                variant="caption"
                                sx={{ fontStyle: 'italic' }}>{moment(e.createdAt).format('DD MMM YYYY hh:mm:ss')}</Typography>
                            {/*<Chip*/}
                            {/*    color={color}*/}
                            {/*    size="small"*/}
                            {/*    label="Transaction"/>*/}
                        </Stack>
                    </Card>
                ))}
            </Stack>
        </Box>
    )
}