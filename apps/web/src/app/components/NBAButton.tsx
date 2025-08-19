'use client';

interface NBAButtonProps {
  label: string;
  description: string;
  onClick: () => void;
  disabled?: boolean;
}

export default function NBAButton({
  label,
  description,
  onClick,
  disabled = false,
}: NBAButtonProps) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className="px-4 py-2 bg-indigo-100 hover:bg-indigo-200 text-indigo-800 rounded-lg text-left disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
      title={description}
    >
      <div className="font-medium text-sm">{label}</div>
      <div className="text-xs text-indigo-600 mt-1">{description}</div>
    </button>
  );
}
