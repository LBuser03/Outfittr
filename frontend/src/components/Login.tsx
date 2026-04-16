import { useState } from 'react';
import { buildPath } from './Path';
import { useNavigate } from 'react-router-dom';
import { storeAccessToken } from '../utils/session';

function Login() {
    const [message, setMessage] = useState('');
    const [loginName, setLoginName] = useState('');
    const [loginPassword, setPassword] = useState('');
    const navigate = useNavigate();

    async function doLogin(event: any): Promise<void> {
        event.preventDefault();

        const obj = { login: loginName, password: loginPassword };

        try {
            const response = await fetch(buildPath('api/login'), {
                method: 'POST',
                body: JSON.stringify(obj),
                headers: { 'Content-Type': 'application/json' }
            });

            const res = await response.json();

            if (res.error || !res.accessToken) {
                setMessage(res.error || 'User/Password incorrect');
                return;
            }

            storeAccessToken(res.accessToken);

            const payload = JSON.parse(atob(res.accessToken.split('.')[1]));
            
            const { userId } = payload;

            if (!userId) {
                setMessage('Invalid token received');
                return;
            }

            const user = { email: loginName, id: userId };
            localStorage.setItem('user_data', JSON.stringify(user));

            setMessage('');
            navigate('/dashboard');

        } catch (error: any) {
            setMessage("Service unavailable. Check if backend is running on port 5001.");
        }
    } 

    return (
        <div id="loginDiv">
            <span id="inner-title">PLEASE LOG IN</span><br />

            <input
                type="text"
                placeholder="Username"
                onChange={(e) => setLoginName(e.target.value)}
            /><br />

            <input
                type="password"
                placeholder="Password"
                onChange={(e) => setPassword(e.target.value)}
            /><br />

            <button onClick={doLogin}>
                Login
            </button>

            <span id="loginResult">{message}</span>
        </div>
    );
}

export default Login;
