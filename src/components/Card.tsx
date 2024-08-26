import { cn } from "../lib/utils";

interface CardProps {
  children: React.ReactNode;
  className?: string;
}

const Card = ({ children, className }: CardProps) => {
  return (
    <div
      className={cn("p-4 border shadow-lg rounded-lg h-fit w-full", className)}
    >
      {children}
    </div>
  );
};

export default Card;
