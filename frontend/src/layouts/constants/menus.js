import {
    AccountTreeRounded,
    BadgeOutlined,
    CampaignRounded, ChecklistRounded,
    CorporateFareRounded,
    DashboardRounded, EventAvailableRounded, InsertInvitationRounded,
    PeopleRounded,
    ReceiptLongRounded,
    SettingsRounded
} from "@mui/icons-material";
import {generateUniqueId} from "utils/helper";
import {Role} from "../../constants/constants";

const Menus = [
    {
        navLabel: true,
        subheader: 'Home',
    },
    {
        id: generateUniqueId(),
        title: 'Dashboard',
        icon: DashboardRounded,
        href: '',
        roles: [Role.employee.value],
    },
    {
        navLabel: true,
        subheader: 'Company',
    },
    {
        id: generateUniqueId(),
        title: 'Announcement',
        icon: CampaignRounded,
        href: '/announcement',
    },
    {
        id: generateUniqueId(),
        title: 'Designation',
        icon: BadgeOutlined,
        href: '/designation',
    },
    {
        id: generateUniqueId(),
        title: 'Department',
        icon: CorporateFareRounded,
        href: '/department',
    },
    {
        navLabel: true,
        subheader: 'Employee',
    },
    {
        id: generateUniqueId(),
        title: 'Attendance',
        icon: EventAvailableRounded,
        href: '/attendance',
        roles: [Role.employee.value],
    },
    {
        id: generateUniqueId(),
        title: 'Leave',
        icon: InsertInvitationRounded,
        href: '/leave',
        roles: [Role.employee.value],
    },
    {
        navLabel: true,
        subheader: 'Project',
    },
    {
        id: generateUniqueId(),
        title: 'Project',
        icon: AccountTreeRounded,
        href: '/project',
    },
    {
        id: generateUniqueId(),
        title: 'Task',
        icon: ChecklistRounded,
        href: '/task',
        roles: [Role.employee.value],
    },
    {
        navLabel: true,
        subheader: 'Finance',
    },
    {
        id: generateUniqueId(),
        title: 'Expense',
        icon: ReceiptLongRounded,
        href: '/expense',
    },
    {
        navLabel: true,
        subheader: 'Setting',
    },
    {
        id: generateUniqueId(),
        title: 'General Setting',
        icon: SettingsRounded,
        href: '/setting',
    },
    {
        id: generateUniqueId(),
        title: 'Users',
        icon: PeopleRounded,
        href: '/user',
    },
];

export default Menus;