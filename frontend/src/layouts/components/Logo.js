import {Stack, useMediaQuery} from "@mui/material";

const Logo = () => {
    const smDown = useMediaQuery((theme) => theme.breakpoints.down('lg'));
    const logoSize = {
        width: smDown ? 100 : 160,
        height: smDown ? 30 : 60
    };

    return (
        <Stack justifyContent="center" alignItems="center">
            <img src="/images/logo/logo.svg" alt="logo" width={logoSize.width} height={logoSize.height}/>
        </Stack>
    )
};

export default Logo;