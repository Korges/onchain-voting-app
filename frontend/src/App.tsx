import { Routes, Route } from "react-router-dom";
import Header from "./components/Header";

function App() {
  return (
    <>
      <Header />

      

      <Routes>
        <Route path="/" element={<p>Hello world</p>} />
        <Route path="/about" element={<p>About page</p>} />
      </Routes>
    </>
  );
}

export default App;
