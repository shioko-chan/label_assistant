from pathlib import Path

class Writer:
    
    def __init__(self):
        self.dst = None
    
    def set_dst(self, path: Path):
        self.dst = path

    # rewrite this function to adapt to your saving method and label format
    def save(self, annotations: list, name):
        with open(self.dst / f"{name}.txt", "w") as f:
            for a in annotations:
                f.write(
                    f"""{a['cls']} {' '.join(map(str, [a['x'], a['y'], a['w'], a['h']]))} {' '.join([f"{p['x']} {p['y']}" for p in a['kpnt']])}\n"""
                )
    
    def exists(self, name):
        return (self.dst / f"{name}.txt").exists()
    
    