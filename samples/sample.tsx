import React, { useState, useEffect } from "react";

interface Props {
  userId: number;
  onLoad?: (name: string) => void;
}

const UserCard: React.FC<Props> = ({ userId, onLoad }) => {
  const [name, setName] = useState<string>("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(`/api/users/${userId}`)
      .then((r) => r.json())
      .then((data) => {
        setName(data.name);
        onLoad?.(data.name);
      })
      .finally(() => setLoading(false));
  }, [userId]);

  if (loading) return <div className="spinner" />;
  return <div className="card">{name}</div>;
};

export default UserCard;
