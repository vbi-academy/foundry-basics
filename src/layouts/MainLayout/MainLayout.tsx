import Header from "./components/Header";

const MainLayout = ({ children }: { children: React.ReactNode }) => {
  return (
    <div className="container mx-auto px-4">
      <Header />
      {children}
    </div>
  );
};

export default MainLayout;
