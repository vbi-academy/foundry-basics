import Button from "./components/Button";
import Card from "./components/Card";
import MainLayout from "./layouts/MainLayout";

function App() {
  return (
    <MainLayout>
      <div className="flex gap-4">
        <Card>
          <p className="text-sm">Donation Information.</p>
          <p>Address:</p>
          <p>Total Amount Funded:</p>
          <p>Total Funders:</p>
        </Card>
        <Card>
          <p className="text-sm">Contribute your Ether.</p>
          <input placeholder="Amount" className="p-2 border rounded-lg" />
          <Button className="w-fit">Fund</Button>
        </Card>
      </div>
    </MainLayout>
  );
}

export default App;
