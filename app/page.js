import Image from "next/image";
import Link from "next/link";

export default function Home() {
  return (
    <div>
      <nav>
        <Link href="/">Home</Link>
        <Link href="/about">About</Link>
      </nav>
      <div className="mt-4">Home page</div>
    </div>
  );
}
