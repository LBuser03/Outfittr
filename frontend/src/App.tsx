import { BrowserRouter, Routes, Route } from "react-router-dom";
import './App.css';
import LoginPage from './pages/LoginPage';
import ItemPage from "./pages/ItemPage";
function App() {
    return (
        <BrowserRouter>
            <Routes>
                <Route path="/" element={<LoginPage />} />
                <Route path="/items" element={<ItemPage />} />
            </Routes>
        </BrowserRouter>
    );
}
export default App;