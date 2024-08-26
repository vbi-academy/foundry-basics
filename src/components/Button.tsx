import { cn } from "../lib/utils";

interface Button {
  children: React.ReactNode;
  className?: string;
  onClick?: () => void;
}

const Button = ({ children, className, onClick }: Button) => {
  return (
    <button
      onClick={onClick}
      className={cn(
        "text-white bg-slate-900 px-3 py-2 rounded-lg hover:bg-slate-700 transition-colors text-sm",
        className
      )}
    >
      {children}
    </button>
  );
};

export default Button;
